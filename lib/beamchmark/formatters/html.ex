defmodule Beamchmark.Formatters.HTML do
  @moduledoc """
  The module formats `#{inspect(Beamchmark.Suite)}` and outputs it to an HTML file.
  """

  @behaviour Beamchmark.Formatter

  alias Beamchmark.Utils
  alias Beamchmark.Suite
  alias __MODULE__.Templates

  @default_output_path "index.html"
  @default_auto_open true
  @default_inline_assets false

  @typedoc """
  Configuration for `#{inspect(__MODULE__)}`.
  * `output_path` – path to the file, where the report will be saved. Defaults to `#{inspect(@default_output_path)}`.
  * `auto_open?` – if `true`, opens the report in system's default browser. Defaults to `#{inspect(@default_auto_open)}`.
  * `inline_assets?` – if `true`, pastes contents of `.css` and `.js` assets directly into HTML. Defaults to `#{inspect(@default_inline_assets)}`.
  """
  @type options_t() :: [
          output_path: Path.t(),
          auto_open?: boolean(),
          inline_assets?: boolean()
        ]

  @impl true
  def format(%Suite{} = suite, options) do
    Templates.index(suite, nil, Keyword.get(options, :inline_assets?, @default_inline_assets))
  end

  @impl true
  def format(%Suite{} = new_suite, %Suite{} = base_suite, options) do
    Templates.index(
      new_suite,
      base_suite,
      Keyword.get(options, :inline_assets?, @default_inline_assets)
    )
  end

  @impl true
  def write(content, options) do
    output_path =
      options |> Keyword.get(:output_path, @default_output_path) |> Path.expand() |> format_path()

    auto_open? = Keyword.get(options, :auto_open?, @default_auto_open)

    dirname = Path.dirname(output_path)

    unless File.exists?(dirname) do
      File.mkdir_p!(dirname)
    end

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

  defp get_browser() do
    case Utils.os() do
      :macOS -> "open"
      :Windows -> "explorer"
      :Linux -> "xdg-open"
    end
  end

  defp format_path(path) do
    case Utils.os() do
      :Windows -> String.replace(path, "/", "\\")
      _ -> path
    end
  end
end
