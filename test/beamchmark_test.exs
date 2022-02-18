defmodule BeamchmarkTest do
  use ExUnit.Case
  doctest Beamchmark

  defmodule TestScenario do
    @moduledoc false

    @behaviour Beamchmark.Scenario

    @impl true
    def run(), do: :ok
  end

  setup do
    tmp_dir = Path.join([System.tmp_dir!(), "beamchmark_test"])
    on_exit(fn -> File.rm_rf!(tmp_dir) end)
    [tmp_dir: tmp_dir]
  end

  test "Beamchmark runs properly", %{tmp_dir: tmp_dir} do
    assert :ok == Beamchmark.run(TestScenario, duration: 1, output_dir: tmp_dir)
    # check wheather Beamchmark can read and compare new results with the previous one
    assert :ok == Beamchmark.run(TestScenario, duration: 1)
  end
end
