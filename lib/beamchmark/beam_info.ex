defmodule Beamchmark.BEAMInfo do
  @moduledoc false
  # module responsible for gathering BEAM statistics and formatting them

  import Beamchmark.Utils
  import Beamchmark.Math

  alias Beamchmark.SchedulerInfo

  @type reductions_t() :: non_neg_integer()
  @type context_switches_t() :: non_neg_integer()

  @type t :: %__MODULE__{
          scheduler_info: Beamchmark.SchedulerInfo.t(),
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
      :scheduler.utilization(duration || 60)
      |> Beamchmark.SchedulerInfo.from_sched_util_result()

    {reductions, _reuctions_from_last_call} = :erlang.statistics(:reductions)

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
    scheduler_info_diff = Beamchmark.SchedulerInfo.diff(base.scheduler_info, new.scheduler_info)

    %__MODULE__{
      scheduler_info: scheduler_info_diff,
      reductions: new.reductions - base.reductions,
      context_switches: new.context_switches - base.context_switches
    }
  end

  @spec format(t()) :: String.t()
  def format(%__MODULE__{} = beam_info), do: format(beam_info, nil)

  @spec format(t(), t() | nil) :: String.t()
  def format(%__MODULE__{} = beam_info, nil) do
    """
    #{SchedulerInfo.format(beam_info.scheduler_info)}

    Reductions
    --------------------
    #{do_format(beam_info.reductions)}\

    Context Switches
    --------------------
    #{do_format(beam_info.context_switches)}
    """
  end

  def format(%__MODULE__{} = beam_info, %__MODULE__{} = beam_info_diff) do
    """
    #{SchedulerInfo.format(beam_info.scheduler_info, beam_info_diff.scheduler_info)}

    Reductions
    --------------------
    #{do_format(beam_info.reductions, beam_info_diff.reductions)}\

    Context Switches
    --------------------
    #{do_format(beam_info.context_switches, beam_info_diff.context_switches)}
    """
  end

  defp do_format(number) when is_integer(number), do: "#{number}"

  defp do_format(number, number_diff) when is_integer(number) and is_integer(number_diff) do
    color = get_color(number_diff)
    # old number = number - number_diff
    percent_diff = percent_diff(number - number_diff, number)

    "#{number} #{color} #{number_diff} #{percent_diff}#{if percent_diff != :nan, do: "%"}#{IO.ANSI.reset()}\n"
  end
end
