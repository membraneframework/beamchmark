defmodule CPUTaskTest do
  use ExUnit.Case
  alias Beamchmark.Suite.CPU.CPUTask
  alias Beamchmark.Formatters.HTML.Templates

  setup do
    # Some tests setup
    :cpu_sup.start()
    :cpu_sup.util([:per_cpu])
    :ok
  end

  test "cpu_task" do
    cpu_task = CPUTask.start_link(10, 1000)
    assert {:ok, _statistics} = Task.await(cpu_task, :infinity)
  end

  test "formatted_average_cpu_usage" do
    cpu_task = CPUTask.start_link(10, 1000)
    assert {:ok, statistics} = Task.await(cpu_task, :infinity)
    result = Templates.formatted_average_cpu_usage(statistics.cpu_snapshots)
    assert true == not is_nil(result)
  end

  test "formatted_cpu_usage_by_core" do
    cpu_task = CPUTask.start_link(1000, 10_000)
    assert {:ok, statistics} = Task.await(cpu_task, :infinity)
    result = Templates.formatted_cpu_usage_by_core(statistics.cpu_snapshots)
    assert true == not is_nil(result)
  end
end
