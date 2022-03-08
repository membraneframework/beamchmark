defmodule Beamchmark.Suite.CPU.CPUTask do
  use Task

  alias Beamchmark.Suite.Measurements.CpuInfo
  # timeout in milliseconds
  @timeout 1000
  # Duration in seconds
  @duration 10

  def start_link(timeout \\ @timeout, duration \\ @duration) do
    Task.async(fn -> run_poll(timeout, duration) end)
  end

  defp start_cpu_sup() do
    :cpu_sup.start()
    # First run returns garbage acc to docs
    :cpu_sup.util([:per_cpu])
  end

  def run_poll(timeout, duration) do
    iterations_number = trunc(duration * 1000 / timeout)
    start_cpu_sup()

    statistics =
      Enum.reduce(0..iterations_number, [], fn _x, acc ->
        snap_statistics(acc, timeout)
      end)

    :cpu_sup.stop()
    get_statistics(statistics)
  end

  @spec get_cpu_usage() :: CpuInfo.cpu_usage_unstable_t()
  def get_cpu_usage do
    :cpu_sup.util([:per_cpu])
    |> CpuInfo.convert_from_cpu_sup_util()
  end

  defp snap_statistics(statistics, timeout) do
    statistics = [get_cpu_usage() | statistics]
    Process.sleep(timeout)
    statistics
  end

  defp get_statistics(statistics) do
    statistics |> CpuInfo.combine_cpu_statistics()
  end
end
