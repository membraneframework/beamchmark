defmodule Beamchmark.FormatterTest do
  use ExUnit.Case, async: true

  alias Beamchmark.{Suite, Formatter}

  @temp_directory TestUtils.temporary_dir(__MODULE__)

  defp put_formatters(suite, formatters) do
    Map.update!(suite, :configuration, &Map.put(&1, :formatters, List.wrap(formatters)))
  end

  setup_all do
    suite = TestUtils.suite_with_measurements(MockScenario, output_dir: @temp_directory)

    [suite: suite]
  end

  describe "Formatter.output/1 validates formatters by" do
    test "accepting valid formatters", %{suite: suite} do
      valid_formatters = [
        [],
        ValidFormatter,
        List.duplicate(ValidFormatter, 3),
        List.duplicate({ValidFormatter, [valid: :options]}, 3),
        [ValidFormatter, {ValidFormatter, [these: :are, valid: :options]}]
      ]

      Enum.each(valid_formatters, fn formatters ->
        assert :ok = suite |> put_formatters(formatters) |> Formatter.output()
      end)
    end

    test "raising on invalid formatters", %{suite: suite} do
      invalid_formatters = [
        InvalidFormatter,
        [ValidFormatter, InvalidFormatter],
        [ValidFormatter, {InvalidFormatter, [valid: :options]}],
        [InvalidFormatter, {ValidFormatter, [valid: :options]}]
      ]

      Enum.each(invalid_formatters, fn formatters ->
        assert_raise RuntimeError, fn ->
          suite |> put_formatters(formatters) |> Formatter.output()
        end
      end)
    end

    test "raising on invalid options", %{suite: suite} do
      invalid_options = [%{invalid: :options}, nil, [1, 2, 3], [{1, 2}, {"a", "b"}]]

      Enum.each(invalid_options, fn options ->
        assert_raise RuntimeError, fn ->
          suite |> put_formatters({ValidFormatter, options}) |> Formatter.output()
        end
      end)
    end
  end

  describe "When formatters are valid, Formatter.output/1" do
    setup %{suite: suite} do
      spy_formatter_options = [pid: self(), not: :important, configuration: :info]

      on_exit(fn -> File.rm_rf!(@temp_directory) end)

      [suite: suite, spy_options: spy_formatter_options]
    end

    test "passes options to formatters", %{suite: suite, spy_options: spy_options} do
      suite = put_formatters(suite, {SpyFormatter, spy_options})

      assert :ok = Formatter.output(suite)
      assert_received {^suite, ^spy_options}
      assert_received {:ok, ^spy_options}
    end

    test "provides base suite if configured to do so", %{suite: suite, spy_options: spy_options} do
      suite =
        suite
        |> Map.update!(:configuration, &Map.put(&1, :compare?, true))
        |> put_formatters({SpyFormatter, spy_options})

      # "base"
      :ok = Suite.save(suite)
      # "new"
      :ok = Suite.save(suite)

      assert :ok = Formatter.output(suite)
      assert_received {^suite, ^suite, ^spy_options}
      assert_received {:ok, ^spy_options}
      refute_received _
    end

    test "does not provide base suite if there is no such", %{
      suite: suite,
      spy_options: spy_options
    } do
      suite =
        suite
        |> Map.update!(:configuration, &Map.put(&1, :compare?, true))
        |> put_formatters({SpyFormatter, spy_options})

      # "new"
      :ok = Suite.save(suite)

      assert :ok = Formatter.output(suite)
      assert_received {^suite, ^spy_options}
      assert_received {:ok, ^spy_options}
      refute_received _
    end

    test "does not provide base suite if configured not to do so", %{
      suite: suite,
      spy_options: spy_options
    } do
      suite = put_formatters(suite, {SpyFormatter, spy_options})

      # "base"
      :ok = Suite.save(suite)
      # "new"
      :ok = Suite.save(suite)

      assert :ok = Formatter.output(suite)
      assert_received {^suite, ^spy_options}
      assert_received {:ok, ^spy_options}
      refute_received _
    end
  end
end
