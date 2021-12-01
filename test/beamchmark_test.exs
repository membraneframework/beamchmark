defmodule BeamchmarkTest do
  use ExUnit.Case
  doctest Beamchmark

  defmodule TestScenario do
    @moduledoc false

    @behaviour Beamchmark.Scenario

    @impl true
    def run(), do: :noop
  end

  test "Beamchmark runs properly" do
    assert :ok == Beamchmark.run(TestScenario, duration: 1)
    # check wheather Beamchmark can read and compare new results with the previous one
    assert :ok == Beamchmark.run(TestScenario, duration: 1)
  end
end
