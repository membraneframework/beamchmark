defmodule Beamchmark.Suite.Measurements.CpuInfo do
  @moduledoc """
  Module representing different statistics about cpu usage.

  Method of measuring
    - Get a few snapshots to stabilize the value
    - Write a value under corresponding time_stamp
    - Get a few of time_stamps and then calculate the average
  """

  use Bunch.Access

  alias Beamchmark.Math

  @typedoc """
  Single core snap statistics
  """
  @type cpu_core_usage_t ::
          {core_id :: integer(), usage :: Math.percent_t() | Math.percent_diff_t()}

  @typedoc """
  Average single core snap statistics
  Gathered by taking a few snapshots and joining them by cores.
  """
  @type average_by_core_t ::
          {core_id :: integer(), usage :: Math.percent_t() | Math.percent_diff_t()}

  @typedoc """
  All information gathered via single snapshot, this value can
  be unstable and needs to be stabilized.
  """
  @type cpu_usage_unstable_t ::
          {time_stamp :: integer(),cpu_usage :: [cpu_core_usage_t()], average_all_cores :: Math.percent_t()}

  @typedoc """
  All information gathered via single snapshot
  including `timestamp` (integer value since start of measuring)
  cpu_usage is average statistics for all cores
  """
  @type cpu_usage_stable_t ::
          {time_stamp :: integer(), cpu_usage :: [average_by_core_t()], average_all_cores :: Math.percent_t()}

  @typedoc """
  All information gathered via single snapshot including averages
  `all_average` is average from all time_stamps
  """
  @type t :: %__MODULE__{
          cpu_usage_stable_t: cpu_usage_stable_t,
          all_average: average_by_core_t()
        }

  defstruct cpu_usage_stable_t: [],
            all_average: {}

  @doc """
  converts output of `:cpu_sup.util([:per_cpu])` to `cpu_usage_unstable_t`
  """
  @spec convert_from_cpu_sup_util(any()) :: cpu_usage_unstable_t()
  def convert_from_cpu_sup_util(cpu_util_result) do
    # TODO
    Enum.reduce(cpu_util_result, [], fn element, acc ->
      current_core = [
        core_id: elem(element, 0),
        usage: elem(element, 1)
      ]

      [current_core | acc]
    end)
  end

  # @doc """
  # Converts list of `cpu_usage_unstable_t` to `cpu_usage_stable_t`
  # By calculating the average and removing outliers
  # """
  # @spec stabilize_cpu_usage([cpu_usage_unstable_t()], integer()) :: cpu_usage_stable_t()
  # def stabilize_cpu_usage(cpu_usage_list, time_stamp) do
  #   # TODO
  # end

  @doc """
  Converts list of `cpu_usage_unstable_t` to ` #{__MODULE__}.t()`
  By calculating the average
  """
  @spec combine_cpu_statistics([cpu_usage_unstable_t()]) :: t()
  def combine_cpu_statistics(cpu_usage_unstable_list) do
    # TODO
    cpu_usage_unstable_list
  end
end
