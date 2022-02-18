defmodule Beamchmark.Measurements do
  @moduledoc """
  The module is responsible for gathering BEAM statistics during benchmarking.
  """

  alias Beamchmark.SchedulerInfo

  @type reductions_t() :: non_neg_integer()
  @type context_switches_t() :: non_neg_integer()

  @type t :: %__MODULE__{
          scheduler_info: SchedulerInfo.t(),
          reductions: reductions_t(),
          context_switches: context_switches_t()
        }

  @enforce_keys [
    :scheduler_info,
    :reductions,
    :context_switches
  ]
  defstruct @enforce_keys

  @spec gather(timeout()) :: %__MODULE__{}
  def gather(duration) do
    scheduler_info =
      :scheduler.utilization(duration)
      |> SchedulerInfo.from_sched_util_result()

    {reductions, _reductions_from_last_call} = :erlang.statistics(:reductions)

    # second element of this tuple is always 0
    {context_switches, 0} = :erlang.statistics(:context_switches)

    %__MODULE__{
      scheduler_info: scheduler_info,
      reductions: reductions,
      context_switches: context_switches
    }
  end

  @spec diff(t(), t()) :: t()
  def diff(base, new) do
    scheduler_info_diff = SchedulerInfo.diff(base.scheduler_info, new.scheduler_info)

    %__MODULE__{
      scheduler_info: scheduler_info_diff,
      reductions: new.reductions - base.reductions,
      context_switches: new.context_switches - base.context_switches
    }
  end
end
