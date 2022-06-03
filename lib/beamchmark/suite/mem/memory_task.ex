defmodule Beamchmark.Suite.Mem.MemoryTask do
  @moduledoc """
  This module contains the memory benchmarking task.
  Measurements are performed using [`:erlang.memory/0`](https://www.erlang.org/doc/man/erlang.html#memory-0)
  Run example:
  ```
  MemoryTask.start_link()
  ```
  """
  use Task

  alias Beamchmark.Suite.Measurements.MemoryInfo

  @spec start_link(mem_interval :: pos_integer(), duration :: pos_integer()) :: Task.t()
  def start_link(mem_interval, duration) do
    Task.async(fn ->
      run_poll(mem_interval, duration)
    end)
  end

  @spec run_poll(number(), number()) :: {:ok, MemoryInfo.t()}
  defp run_poll(mem_interval, duration) do
    iterations_number = trunc(duration / mem_interval)

    memory_snapshots =
      Enum.reduce(0..(iterations_number - 1), [], fn _x, memory_snapshots ->
        memory_snapshots = [memory_snapshot() | memory_snapshots]
        Process.sleep(mem_interval)
        memory_snapshots
      end)

    {:ok, MemoryInfo.from_memory_snapshots(memory_snapshots)}
  end

  defp memory_snapshot() do
    :erlang.memory() |> Enum.into(%{})
  end
end
