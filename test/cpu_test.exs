defmodule CpuTaskTest do
  use ExUnit.Case
  alias Beamchmark.Suite.CPU.CpuTask

  test "CpuTask.start_link/2 runs properly" do
    cpu_interval = 100
    duration = 15_000

    cpu_task =
      CpuTask.start_link(
        cpu_interval,
        duration
      )

    assert {:ok, cpu_info} = Task.await(cpu_task, :infinity)
    assert !is_nil(cpu_info.average_by_core)
    assert !is_nil(cpu_info.cpu_snapshots)
    assert !is_nil(cpu_info.average_all)

    assert duration / cpu_interval == length(cpu_info.cpu_snapshots)
  end
end
