defmodule Beamchmark.Suite.Measurements do
  @moduledoc """
  The module is responsible for gathering BEAM statistics during benchmarking.
  """

  alias __MODULE__.CpuInfo
  alias __MODULE__.MemoryInfo
  alias __MODULE__.SchedulerInfo
  alias Beamchmark.Suite.CPU.CpuTask
  alias Beamchmark.Suite.Memory.MemoryTask

  @type reductions_t() :: non_neg_integer()
  @type context_switches_t() :: non_neg_integer()

  @type t :: %__MODULE__{
          scheduler_info: SchedulerInfo.t(),
          cpu_info: CpuInfo.t(),
          memory_info: MemoryInfo.t(),
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
    :cpu_info,
    :memory_info
  ]

  @spec gather(pos_integer(), pos_integer(), pos_integer()) :: t()
  def gather(duration, cpu_interval, memory_interval) do
    sample = :scheduler.sample_all()

    cpu_task = CpuTask.start_link(cpu_interval, duration * 1000)
    memory_task = MemoryTask.start_link(memory_interval, duration * 1000)

    Process.sleep(:timer.seconds(duration))

    scheduler_info =
      sample
      |> :scheduler.utilization()
      |> SchedulerInfo.from_sched_util_result()

    {reductions, _reductions_from_last_call} = :erlang.statistics(:reductions)

    # second element of this tuple is always 0
    {context_switches, 0} = :erlang.statistics(:context_switches)

    {:ok, cpu_info} = Task.await(cpu_task, :infinity)
    {:ok, memory_info} = Task.await(memory_task, :infinity)

    %__MODULE__{
      scheduler_info: scheduler_info,
      reductions: reductions,
      context_switches: context_switches,
      cpu_info: cpu_info,
      memory_info: memory_info
    }
  end

  @spec diff(t(), t()) :: t()
  def diff(base, new) do
    scheduler_info_diff = SchedulerInfo.diff(base.scheduler_info, new.scheduler_info)
    cpu_info_diff = CpuInfo.diff(base.cpu_info, new.cpu_info)
    memory_info_diff = MemoryInfo.diff(base.memory_info, new.memory_info)

    %__MODULE__{
      scheduler_info: scheduler_info_diff,
      reductions: new.reductions - base.reductions,
      context_switches: new.context_switches - base.context_switches,
      cpu_info: cpu_info_diff,
      memory_info: memory_info_diff
    }
  end
end
