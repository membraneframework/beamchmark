defmodule Beamchmark.Suite.Measurements do
  @moduledoc """
  The module is responsible for gathering BEAM statistics during benchmarking.
  """

  alias __MODULE__.SchedulerInfo
  alias __MODULE__.CpuInfo
  alias Beamchmark.Suite.CPU.CPUTask

  @type reductions_t() :: non_neg_integer()
  @type context_switches_t() :: non_neg_integer()

  @type t :: %__MODULE__{
          scheduler_info: SchedulerInfo.t(),
          cpu_info: CpuInfo.t() | nil,
          reductions: reductions_t(),
          context_switches: context_switches_t()
        }

  @enforce_keys [
    :scheduler_info,
    :reductions,
    :context_switches
  ]
  defstruct [
    :scheduler_info,
    :reductions,
    :context_switches,
    :cpu_info
  ]

  @spec gather(pos_integer()) :: t()
  def gather(duration) do
    sample = :scheduler.sample_all()

    Process.sleep(:timer.seconds(duration))

    scheduler_info =
      sample
      |> :scheduler.utilization()
      |> SchedulerInfo.from_sched_util_result()

    {reductions, _reductions_from_last_call} = :erlang.statistics(:reductions)

    # second element of this tuple is always 0
    {context_switches, 0} = :erlang.statistics(:context_switches)

    # Gather cpu load
    cpu_task = CPUTask.start_link()

    {:ok, cpu_info} = Task.await(cpu_task, :infinity)

    %__MODULE__{
      scheduler_info: scheduler_info,
      reductions: reductions,
      context_switches: context_switches,
      cpu_info: cpu_info
    }
  end

  @spec diff(t(), t()) :: t()
  def diff(base, new) do
    scheduler_info_diff = SchedulerInfo.diff(base.scheduler_info, new.scheduler_info)
    cpu_info_diff = CpuInfo.diff(base.cpu_info, new.cpu_info)

    %__MODULE__{
      scheduler_info: scheduler_info_diff,
      reductions: new.reductions - base.reductions,
      context_switches: new.context_switches - base.context_switches,
      cpu_info: cpu_info_diff
    }
  end
end
