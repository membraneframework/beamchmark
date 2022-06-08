defmodule MemoryTaskTest do
  use ExUnit.Case

  alias Beamchmark.Suite.Memory.MemoryTask

  test("MemoryTask.start_link/2 runs properly") do
    mem_interval = 100
    duration = 15_000

    mem_task =
      MemoryTask.start_link(
        mem_interval,
        duration
      )

    assert {:ok, mem_info} = Task.await(mem_task, :infinity)
    assert !is_nil(mem_info.average.total)
    assert !is_nil(mem_info.memory_snapshots)

    assert duration / mem_interval == length(mem_info.memory_snapshots)
  end
end
