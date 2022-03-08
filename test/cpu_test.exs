defmodule CPUTaskTest do
  use ExUnit.Case
  alias Beamchmark.Suite.CPU.CPUTask

  setup do
    # Some tests setup
    :cpu_sup.start()
    :cpu_sup.util([:per_cpu])
    :ok
  end

  test "cpu_task" do
    cpu_task = CPUTask.start_link(1000, 10)
    result = Task.await(cpu_task, :infinity)
    IO.puts("Result measurements for CPU task:")
    IO.inspect(result)
    assert :ok == :ok
  end
end
