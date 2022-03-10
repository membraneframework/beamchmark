defmodule Beamchmark.Suite.Measurements.CpuInfo do
  @moduledoc """
  Module representing statistics about cpu usage.

  Method of measuring:
    - Take a snapshot of cpu usage every `@interval` milliseconds
    - Calculate the average cpu usage of processor (combining each core usage)
    - At the end combine the results and calculate the average

  **Warning!**
    This module can give unstable cpu usage values when measuring a short time because of a high cpu volatility.
    TODO Can be improved by taking average of 5-10 values for each snapshot
  """

  use Bunch.Access
  alias Beamchmark.Math

  @typedoc """
  All information gathered via single snapshot + processor average
  """
  @type cpu_usage_t ::
          %{
            cpu_usage:
              cpu_usage :: %{
                (core_id :: integer()) => usage :: Math.percent_t() | Math.percent_diff_t()
              },
            average_all_cores: average_all_cores :: Math.percent_t()
          }

  @typedoc """
  All information gathered via all snapshots
  `all_average` is average from all snapshots
  """
  @type t :: %__MODULE__{
          cpu_snapshots: [cpu_usage_t()],
          average_by_core:
            average_by_core ::
              %{
                (core_id :: number()) => usage :: Math.percent_t()
              }
              | nil,
          average_all: Math.percent_t()
        }

  defstruct cpu_snapshots: [],
            average_by_core: %{},
            average_all: 0

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

    sum_by_core =
      Enum.reduce(cpu_usage_unstable_list, %{}, fn %{cpu_usage: cpu_usage}, sum_cores_acc ->
        cpu_usage |> reduce_cpu_usage(sum_cores_acc)
      end)

    number_of_snapshots = length(cpu_usage_unstable_list)

    average_by_core =
      Enum.reduce(sum_by_core, %{}, fn {core_id, value}, acc ->
        Map.put(acc, core_id, Float.round(value / number_of_snapshots, 2))
      end)

    %__MODULE__{
      cpu_snapshots: cpu_usage_unstable_list,
      average_by_core: average_by_core,
      average_all: average_all
    }
  end

  @spec diff(t(), t()) :: t()
  def diff(base, new) do
    # TODO Calculate average by core difference

    average_by_core_diff =
      Enum.reduce(new.average_by_core, %{}, fn {core_id, value}, acc ->
        Map.put(acc, core_id, value - Map.get(base.average_by_core, core_id))
      end)

    %__MODULE__{
      cpu_snapshots: base.cpu_snapshots,
      average_all: new.average_all - base.average_all,
      average_by_core: average_by_core_diff
    }
  end

  defp reduce_cpu_usage(cpu_usage, sum_cores_acc) do
    Enum.reduce(cpu_usage, sum_cores_acc, fn {key, value}, current_sum_cores ->
      Map.update(current_sum_cores, key, value, fn el -> el + value end)
    end)
  end
end
