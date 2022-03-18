defmodule Beamchmark.Suite.Measurements.CpuInfo do
  @moduledoc """
  Module representing statistics about cpu usage.

  Method of measuring:
    - Take a snapshot of cpu usage every `cpu_interval` milliseconds
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
  @type cpu_snapshot_t ::
          %{
            cpu_usage: %{
              (core_id :: integer()) => usage :: Math.percent_t()
            },
            average_all_cores: average_all_cores :: Math.percent_t()
          }

  @typedoc """
  All information gathered via all snapshots
  `all_average` is average from all snapshots
  """
  @type t :: %__MODULE__{
          cpu_snapshots: [cpu_snapshot_t()] | nil,
          average_by_core: %{
            (core_id :: number()) => usage :: Math.percent_t() | float()
          },
          average_all: Math.percent_t() | float()
        }

  defstruct cpu_snapshots: [],
            average_by_core: %{},
            average_all: 0

  @doc """
  Converts list of `cpu_snapshot_t` to ` #{__MODULE__}.t()`
  By calculating the average
  """
  @spec from_cpu_snapshots([cpu_snapshot_t()]) :: t()
  def from_cpu_snapshots(cpu_snapshots) do
    average_all =
      Enum.reduce(cpu_snapshots, 0, fn map, average_all_acc ->
        average_all_acc + map.average_all_cores
      end) / length(cpu_snapshots)

    sum_by_core =
      Enum.reduce(cpu_snapshots, %{}, fn %{cpu_usage: cpu_usage}, sum_cores_acc ->
        reduce_cpu_usage(cpu_usage, sum_cores_acc)
      end)

    number_of_snapshots = length(cpu_snapshots)

    average_by_core =
      Enum.reduce(sum_by_core, %{}, fn {core_id, value}, average_by_core_acc ->
        Map.put(average_by_core_acc, core_id, value / number_of_snapshots)
      end)

    %__MODULE__{
      cpu_snapshots: cpu_snapshots,
      average_by_core: average_by_core,
      average_all: average_all
    }
  end

  @spec diff(t(), t()) :: t()
  def diff(base, new) do
    average_by_core_diff =
      Enum.reduce(new.average_by_core, %{}, fn {core_id, new_core_avg},
                                               average_by_core_diff_acc ->
        Map.put(
          average_by_core_diff_acc,
          core_id,
          new_core_avg - Map.fetch!(base.average_by_core, core_id)
        )
      end)

    %__MODULE__{
      cpu_snapshots: nil,
      average_all: new.average_all - base.average_all,
      average_by_core: average_by_core_diff
    }
  end

  defp reduce_cpu_usage(cpu_usage, sum_cores_acc) do
    Enum.reduce(cpu_usage, sum_cores_acc, fn {core_id, usage}, sum_cores_acc ->
      Map.update(sum_cores_acc, core_id, usage, &(&1 + usage))
    end)
  end
end
