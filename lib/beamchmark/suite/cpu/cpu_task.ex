defmodule Beamchmark.Suite.CPU.CPUTask do
  @moduledoc """
  This module contains the CPU benchmarking task.

  Run example:
  ```
  CPUTask.start_link()
  ```
  """
  use Task

  alias Beamchmark.Suite.Measurements.CpuInfo
  # interval in milliseconds
  @interval 1000
  # Duration in milliseconds
  @duration 10_000

  @spec start_link(number, number) :: Task.t()
  def start_link(interval \\ @interval, duration \\ @duration) do
    Task.async(fn -> run_poll(interval, duration) end)
  end

  @spec run_poll(number, number) :: {:ok, CpuInfo.t()} | {:err, String.t()}
  defp run_poll(interval, duration) do
    iterations_number = trunc(duration / interval)
    :cpu_sup.start()
    # First run returns garbage acc to docs
    :cpu_sup.util([:per_cpu])

    cpu_snapshots =
      Enum.reduce(0..iterations_number, [], fn _x, cpu_snapshots ->
        cpu_snapshots = [cpu_snapshot() | cpu_snapshots]
        Process.sleep(interval)
        cpu_snapshots
      end)

    {:ok, CpuInfo.combine_cpu_statistics(cpu_snapshots)}
  end

  @spec cpu_snapshot() :: CpuInfo.cpu_usage_t()
  defp cpu_snapshot do
    :cpu_sup.util([:per_cpu])
    |> to_cpu_snapshot()
  end

  @doc """
  converts output of `:cpu_sup.util([:per_cpu])` to `cpu_usage_t`
  """
  @spec to_cpu_snapshot(any()) :: CpuInfo.cpu_usage_t()
  def to_cpu_snapshot(cpu_util_result) do
    cpu_core_usage_map =
      Enum.reduce(cpu_util_result, %{}, fn {core_id, usage, _idle, _mix}, acc ->
        Map.put(acc, core_id, usage)
      end)

    average_all_cores =
      Enum.reduce(cpu_core_usage_map, 0, fn {_core_id, usage}, acc ->
        acc + usage
      end) / map_size(cpu_core_usage_map)

    %{
      cpu_usage: cpu_core_usage_map,
      average_all_cores: average_all_cores
    }
  end
end
