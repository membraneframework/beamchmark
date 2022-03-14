defmodule CPUTaskTest do
  use ExUnit.Case
  alias Beamchmark.Suite.CPU.CPUTask

  test "cpu_task" do
    cpu_task = CPUTask.start_link(10, 1000)
    assert {:ok, _statistics} = Task.await(cpu_task, :infinity)
  end
end
