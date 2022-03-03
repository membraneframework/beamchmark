defmodule Beamchmark.Formatters.ConsoleTest do
  use ExUnit.Case, async: true

  alias Beamchmark.Formatters.Console

  @temp_directory TestUtils.temporary_dir(__MODULE__)

  setup_all do
    suite = TestUtils.suite_with_measurements(MockScenario, output_dir: @temp_directory)

    on_exit(fn -> File.rm_rf!(@temp_directory) end)

    [suite: suite]
  end

  describe "Console formatter" do
    test "returns a string from format/2", %{suite: suite} do
      assert is_binary(Console.format(suite, []))
    end

    test "returns a string from format/3", %{suite: suite} do
      assert is_binary(Console.format(suite, suite, []))
    end

    test "on format/2 generates reports of predictable size", %{suite: suite} do
      report = Console.format(suite, [])

      expected_size = 1000

      assert_in_delta byte_size(report), expected_size, 0.1 * expected_size
    end

    test "on format/3 generates reports of predictable size", %{suite: suite} do
      report = Console.format(suite, suite, [])

      expected_size = 2000

      assert_in_delta byte_size(report), expected_size, 0.1 * expected_size
    end

    test "returns :ok from write/2" do
      assert :ok = Console.write("should print on console", [])
    end
  end
end
