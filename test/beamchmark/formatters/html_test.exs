defmodule Beamchmark.Formatters.HTMLTest do
  use ExUnit.Case, async: true

  alias Beamchmark.Formatters.HTML
  alias Beamchmark.Formatters.HTML.Templates
  alias Beamchmark.Suite.CPU.CpuTask

  @temp_directory TestUtils.temporary_dir(__MODULE__)
  @assets_paths TestUtils.html_assets_paths()

  setup_all do
    suite = TestUtils.suite_with_measurements(MockScenario, output_dir: @temp_directory)

    on_exit(fn -> File.rm_rf!(@temp_directory) end)

    [suite: suite]
  end

  describe "HTML formatter" do
    test "format/2 returns a string", %{suite: suite} do
      assert is_binary(HTML.format(suite, []))
    end

    test "format/3 returns a string", %{suite: suite} do
      assert is_binary(HTML.format(suite, suite, []))
    end

    test "format/2 respects inline_assets? flag", %{suite: suite} do
      html_assets_linked = HTML.format(suite, inline_assets?: false)
      html_assets_inlined = HTML.format(suite, inline_assets?: true)

      Enum.each(@assets_paths, fn asset_path ->
        assert String.contains?(html_assets_linked, asset_path)
        assert String.contains?(html_assets_inlined, File.read!(asset_path))
      end)
    end

    test "format/3 respects inline_assets? flag", %{suite: suite} do
      html_assets_linked = HTML.format(suite, suite, inline_assets?: false)
      html_assets_inlined = HTML.format(suite, suite, inline_assets?: true)

      Enum.each(@assets_paths, fn asset_path ->
        assert String.contains?(html_assets_linked, asset_path)
        assert String.contains?(html_assets_inlined, File.read!(asset_path))
      end)
    end

    test "format/2 generates reports of predictable size", %{suite: suite} do
      html_assets_linked = HTML.format(suite, inline_assets?: false)
      html_assets_inlined = HTML.format(suite, inline_assets?: true)

      expected_size_linked = 20_000
      expected_size_inlined = 3_670_000

      assert_in_delta byte_size(html_assets_linked),
                      expected_size_linked,
                      0.5 * expected_size_linked

      assert_in_delta byte_size(html_assets_inlined),
                      expected_size_inlined,
                      0.5 * expected_size_inlined
    end

    test "format/3 generates reports of predictable size", %{suite: suite} do
      html_assets_linked = HTML.format(suite, suite, inline_assets?: false)
      html_assets_inlined = HTML.format(suite, suite, inline_assets?: true)

      expected_size_linked = 20_000
      expected_size_inlined = 3_670_000

      assert_in_delta byte_size(html_assets_linked),
                      expected_size_linked,
                      0.5 * expected_size_linked

      assert_in_delta byte_size(html_assets_inlined),
                      expected_size_inlined,
                      0.5 * expected_size_inlined
    end

    test "write/2 returns :ok and creates an html file" do
      mock_html = "some html content here"
      options = [output_path: Path.join([@temp_directory, "test.html"]), auto_open?: false]

      assert :ok = HTML.write(mock_html, options)
      assert File.exists?(options[:output_path])
      assert File.read!(options[:output_path]) == mock_html
    end

    test "format_average_cpu_usage/1 runs and doesn't return nil" do
      cpu_task =
        CpuTask.start_link(
          100,
          1000
        )

      assert {:ok, statistics} = Task.await(cpu_task, :infinity)
      result = Templates.format_average_cpu_usage(statistics.cpu_snapshots)
      assert true == not is_nil(result)
    end

    test "format_cpu_usage_by_core/1 runs and doesn't return nil" do
      cpu_task =
        CpuTask.start_link(
          1000,
          10_000
        )

      assert {:ok, statistics} = Task.await(cpu_task, :infinity)
      result = Templates.format_cpu_usage_by_core(statistics.cpu_snapshots)
      assert true == not is_nil(result)
    end
  end
end
