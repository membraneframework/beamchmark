defmodule Beamchmark.Suite.CPU.CpuTask do
  @moduledoc """
  This module contains the CPU benchmarking task.
  Measurements are performed using [`:cpu_sup.util/1`](https://www.erlang.org/doc/man/cpu_sup.html)
  Currently (according to docs), as busy processor states we identify:
    - user
    - nice_user (low priority use mode)
    - kernel
  Run example:
  ```
  CpuTask.start_link()
  ```
  """
  use Task

  alias Beamchmark.Suite.Measurements.CpuInfo

  @interfere_timeout 100

  @doc """

  """
  @spec start_link(cpu_interval :: pos_integer(), duration :: pos_integer()) :: Task.t()
  def start_link(cpu_interval, duration) do
    Task.async(fn ->
      run_poll(
        cpu_interval,
        duration
      )
    end)
  end

  @spec run_poll(number(), number()) :: {:ok, CpuInfo.t()}
  defp run_poll(cpu_interval, duration) do
    iterations_number = trunc(duration / cpu_interval)
    :cpu_sup.start()
    # First run returns garbage acc to docs
    :cpu_sup.util([:per_cpu])
    # And the fact of measurement is polluting the results,
    # So we need to wait for @interfere_timeout
    Process.sleep(@interfere_timeout)

    if cpu_interval < @interfere_timeout do
      raise "cpu_interval (#{cpu_interval}) can't be less than #{@interfere_timeout}"
    end

    cpu_snapshots =
      Enum.reduce(0..(iterations_number - 1), [], fn _x, cpu_snapshots ->
        cpu_snapshots = [cpu_snapshot() | cpu_snapshots]
        Process.sleep(cpu_interval)
        cpu_snapshots
      end)

    {:ok, CpuInfo.from_cpu_snapshots(cpu_snapshots)}
  end

  @spec cpu_snapshot() :: CpuInfo.cpu_snapshot_t()
  defp cpu_snapshot() do
    IO.inspect(:cpu_sup.util([:per_cpu]))
    |> to_cpu_snapshot()
  end

  # Converts output of `:cpu_sup.util([:per_cpu])` to `cpu_snapshot_t`
  @spec to_cpu_snapshot(any()) :: CpuInfo.cpu_snapshot_t()
  defp to_cpu_snapshot(cpu_util_result) when is_list(cpu_util_result) do
    cpu_core_usage_map =
      Enum.reduce(cpu_util_result, %{}, fn {core_id, usage, _idle, _mix}, cpu_core_usage_acc ->
        Map.put(cpu_core_usage_acc, core_id, usage)
      end)

    average_all_cores =
      Enum.reduce(cpu_core_usage_map, 0, fn {_core_id, usage}, average_all_cores_acc ->
        average_all_cores_acc + usage
      end) / map_size(cpu_core_usage_map)

    %{
      cpu_usage: cpu_core_usage_map,
      average_all_cores: average_all_cores
    }
  end

  defp to_cpu_snapshot({:all, avg_usage, _non_busy, _misc}) do
    %{
      cpu_usage: %{all: avg_usage / 1},
      average_all_cores: avg_usage / 1
    }
  end
end
