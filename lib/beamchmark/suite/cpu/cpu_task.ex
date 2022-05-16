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

  alias Beamchmark.Utils
  alias Beamchmark.Suite.Measurements.CpuInfo

  @interfere_timeout 100

  @doc """

  """
  @spec start_link(cpu_interval :: pos_integer(), duration :: pos_integer()) :: Task.t()
  def start_link(cpu_interval, duration) do
    Task.async(fn ->
      run_poll(cpu_interval, duration)
    end)
  end

  @spec run_poll(number(), number()) :: {:ok, CpuInfo.t()}
  defp run_poll(cpu_interval, duration) do
    do_run_poll(Utils.get_os_name(), cpu_interval, duration)
  end

  @spec do_run_poll(atom(), number(), number()) :: {:ok, CpuInfo.t()}
  defp do_run_poll(:Windows, cpu_interval, duration) do
    iterations_number = trunc(duration / cpu_interval)
    pid = self()

    Task.async(fn ->
      Enum.each(0..(iterations_number - 1), fn _it_num ->
        spawn(__MODULE__, :cpu_snapshot, [:Windows, pid])
        Process.sleep(cpu_interval)
      end)
    end)

    cpu_snapshots = receive_snapshots(iterations_number)
    {:ok, CpuInfo.from_cpu_snapshots(cpu_snapshots)}
  end

  defp do_run_poll(_os, cpu_interval, duration) do
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

  defp receive_snapshots(snapshots_no, cpu_snapshots \\ []) do
    case snapshots_no do
      0 ->
        cpu_snapshots

      _snapshots_no ->
        cpu_snapshots =
          receive do
            {:cpu_snapshot, snapshot} ->
              IO.puts("received snapshot")
              [snapshot | cpu_snapshots]
          end

        receive_snapshots(snapshots_no - 1, cpu_snapshots)
    end
  end

  @spec cpu_snapshot(:Windows, pid()) :: nil
  def(cpu_snapshot(:Windows, pid)) do
    {cpu_util_result, 0} = System.cmd("wmic", ["cpu", "get", "loadpercentage"])

    average_all_cores =
      try do
        cpu_util_result
        |> String.split("\r\r\n")
        |> Enum.at(1)
        |> String.trim()
        |> Float.parse()
        |> elem(0)
      rescue
        ArgumentError -> 0.0
      end

    send(
      pid,
      {:cpu_snapshot,
       %{
         cpu_usage: %{},
         average_all_cores: average_all_cores
       }}
    )
  end

  @spec cpu_snapshot() :: CpuInfo.cpu_snapshot_t()
  defp cpu_snapshot() do
    cpu_util_result = :cpu_sup.util([:per_cpu])

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
end
