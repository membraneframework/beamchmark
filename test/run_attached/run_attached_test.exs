defmodule RunAttachedTest do
  use ExUnit.Case

  test "Beamchmark.run_attached/2 runs properly" do
    Task.async(fn ->
      System.cmd("sh", [
        "-c",
        "mix run test/run_attached/start_node.exs"
      ])
    end)

    Process.sleep(2000)

    assert Beamchmark.run_attached(:run_attached_test@localhost, duration: 1, cpu_interval: 200) ==
             :ok
  end
end
