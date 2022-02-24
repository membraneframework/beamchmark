defmodule Beamchmark.Formatters.HTML do
  @moduledoc """
  The module formats `#{inspect(Beamchmark.Suite)}` and outputs it to an HTML file.
  """

  @behaviour Beamchmark.Formatter

  @default_output_file "index.html"
  @default_auto_open true

  alias Beamchmark.Suite
  alias __MODULE__.Templates

  @impl true
  def format(%Suite{} = suite, _options) do
    Templates.index(suite, nil)
  end

  @impl true
  def format(%Suite{} = new_suite, %Suite{} = base_suite, _options) do
    Templates.index(new_suite, base_suite)
  end

  @impl true
  def write(content, options) do
    output_path = options |> Map.get(:output_path, @default_output_file) |> Path.expand()
    auto_open? = Map.get(options, :auto_open, @default_auto_open)

    File.write!(output_path, content)
    Mix.shell().info("The HTML file was successfully saved under #{output_path}!")

    maybe_open_report(output_path, auto_open?)
  end

  defp maybe_open_report(_path_to_html, false), do: :ok

  defp maybe_open_report(path_to_html, true) do
    browser = get_browser()
    {_, exit_code} = System.cmd(browser, [path_to_html])

    if exit_code > 0 do
      Mix.shell().error("Failed to open report using \"#{browser}\".")
    else
      Mix.shell().info("Opened report using \"#{browser}\".")
    end
  end

  defp get_browser do
    case :os.type() do
      {:unix, :darwin} -> "open"
      {:unix, _} -> "xdg-open"
      {:win32, _} -> "explorer"
    end
  end
end
