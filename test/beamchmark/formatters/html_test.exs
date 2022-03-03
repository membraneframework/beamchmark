defmodule Beamchmark.Formatters.HTMLTest do
  use ExUnit.Case, async: true

  alias Beamchmark.Formatters.HTML

  @temp_directory TestUtils.temporary_dir(__MODULE__)
  @assets_paths TestUtils.html_assets_paths()

  setup_all do
    suite = TestUtils.suite_with_measurements(MockScenario, output_dir: @temp_directory)

    on_exit(fn -> File.rm_rf!(@temp_directory) end)

    [suite: suite]
  end

  describe "HTML formatter" do
    test "returns a string from format/2", %{suite: suite} do
      assert is_binary(HTML.format(suite, []))
    end

    test "returns a string from format/3", %{suite: suite} do
      assert is_binary(HTML.format(suite, suite, []))
    end

    test "write/2 returns :ok and creates an html file" do
      mock_html = "some html content here"
      options = [output_path: Path.join([@temp_directory, "test.html"]), auto_open?: false]

      assert :ok = HTML.write(mock_html, options)
      assert File.exists?(options[:output_path])
      assert File.read!(options[:output_path]) == mock_html
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
  end
end
