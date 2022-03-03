defmodule Beamchmark.ApplicationTest do
  use ExUnit.Case, async: true
  doctest Beamchmark

  @temp_directory TestUtils.temporary_dir(__MODULE__)

  setup do
    options = [delay: 0, duration: 1, output_dir: @temp_directory, compare?: true, formatters: []]

    on_exit(fn -> File.rm_rf!(@temp_directory) end)

    [options: options]
  end

  test "Beamchmark runs properly", %{options: options} do
    assert :ok == Beamchmark.run(MockScenario, options)
    # check whether Beamchmark can read and compare new results with the previous one
    assert :ok == Beamchmark.run(MockScenario, options)
  end
end
