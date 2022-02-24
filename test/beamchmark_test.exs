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
    temp_directory = Path.join([System.tmp_dir!(), "beamchmark_test"])
    on_exit(fn -> File.rm_rf!(temp_directory) end)
    options = [delay: 0, duration: 1, output_dir: temp_directory, compare?: true, formatters: []]
    [options: options]
  end

  test "Beamchmark runs properly", %{options: options} do
    assert :ok == Beamchmark.run(TestScenario, options)
    # check whether Beamchmark can read and compare new results with the previous one
    assert :ok == Beamchmark.run(TestScenario, options)
  end
end
