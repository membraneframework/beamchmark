defmodule Beamchmark.Suite.Measurements.CpuInfo do
  @moduledoc """
  Module representing statistics about cpu usage.

  Method of measuring:
    - Take a snapshot of cpu usage every `@timeout` milliseconds
    - Calculate the average cpu usage of processor (combining each core usage)
    - At the end combine the results and calculate the average

  **Warning!**
    This module can give unstable cpu usage values when measuring a short time because of a high cpu volatility.
    TODO Can be improved by taking average of 5-10 values for each snapshot
  """

  use Bunch.Access
  alias Beamchmark.Math

  @typedoc """
  Single core snap statistics gathered via snapshot
  """
  @type cpu_core_usage_t ::
          %{(core_id :: integer()) => usage :: Math.percent_t() | Math.percent_diff_t()}

  @typedoc """
  All information gathered via single snapshot + processor average
  """
  @type cpu_usage_t ::
          %{
            cpu_usage: cpu_usage :: [cpu_core_usage_t()],
            average_all_cores: average_all_cores :: Math.percent_t()
          }

  @typedoc """
  All information gathered via all snapshots
  `all_average` is average from all snapshots
  """
  @type t :: %__MODULE__{
          cpu_snapshots: [cpu_usage_t()],
          average_all: Math.percent_t()
        }

  defstruct cpu_snapshots: [],
            average_all: 0

  @doc """
  converts output of `:cpu_sup.util([:per_cpu])` to `cpu_usage_t`
  """
  @spec convert_from_cpu_sup_util(any()) :: cpu_usage_t()
  def convert_from_cpu_sup_util(cpu_util_result) do
    cpu_core_usage_list =
      Enum.reduce(cpu_util_result, [], fn {core_id, usage, _idle, _mix}, acc ->
        cpu_core_usage = %{
          core_id: core_id,
          usage: usage
        }

        [cpu_core_usage | acc]
      end)

    average_all_cores =
      Enum.reduce(cpu_core_usage_list, 0, fn map, acc ->
        acc + map.usage
      end) / length(cpu_core_usage_list)

    %{
      cpu_usage: cpu_core_usage_list,
      average_all_cores: average_all_cores
    }
  end

  @doc """
  Converts list of `cpu_usage_t` to ` #{__MODULE__}.t()`
  By calculating the average
  """
  @spec combine_cpu_statistics([cpu_usage_t()]) :: t()
  def combine_cpu_statistics(cpu_usage_unstable_list) do
    average_all =
      Enum.reduce(cpu_usage_unstable_list, 0, fn map, acc ->
        acc + map.average_all_cores
      end) / length(cpu_usage_unstable_list)

    %__MODULE__{
      cpu_snapshots: cpu_usage_unstable_list,
      average_all: average_all
    }
  end
end
