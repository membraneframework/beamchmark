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
  # timeout in milliseconds
  @timeout 1000
  # Duration in milliseconds
  @duration 10_000

  @spec start_link(number, number) :: Task.t()
  def start_link(timeout \\ @timeout, duration \\ @duration) do
    Task.async(fn -> run_poll(timeout, duration) end)
  end

  defp start_cpu_sup() do
    :cpu_sup.start()
    # First run returns garbage acc to docs
    :cpu_sup.util([:per_cpu])
    :ok
  end

  @spec run_poll(number, number) :: {:ok, CpuInfo.t()} | {:err, String.t()}
  defp run_poll(timeout, duration) do
    iterations_number = trunc(duration / timeout)
    :ok = start_cpu_sup()

    statistics =
      Enum.reduce(0..iterations_number, [], fn _x, acc ->
        snap_statistics(acc, timeout)
      end)

    {:ok, get_statistics(statistics)}
  end

  @spec get_cpu_usage() :: CpuInfo.cpu_usage_t()
  defp get_cpu_usage do
    :cpu_sup.util([:per_cpu])
    |> CpuInfo.convert_from_cpu_sup_util()
  end

  @spec snap_statistics([CpuInfo.cpu_usage_t()], number) ::
          [CpuInfo.cpu_usage_t()]
  defp snap_statistics(statistics, timeout) do
    statistics = [get_cpu_usage() | statistics]
    Process.sleep(timeout)
    statistics
  end

  @spec get_statistics([CpuInfo.cpu_usage_t()]) ::
          CpuInfo.t()
  defp get_statistics(statistics) do
    statistics |> CpuInfo.combine_cpu_statistics()
  end
end
