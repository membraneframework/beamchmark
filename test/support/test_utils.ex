defmodule TestUtils do
  @moduledoc false

  alias Beamchmark.{Scenario, Suite}

  @spec temporary_dir(module()) :: Path.t()
  def temporary_dir(test_module) do
    Path.join([System.tmp_dir!(), test_module |> Atom.to_string() |> String.replace(".", "_")])
  end

  @spec suite_with_measurements(Scenario.t(), Beamchmark.options_t()) :: Suite.t()
  def suite_with_measurements(scenario, opts \\ []) do
    config = %Suite.Configuration{
      duration: Keyword.get(opts, :duration, 1),
      delay: Keyword.get(opts, :delay, 0),
      cpu_interval: Keyword.get(opts, :cpu_interval, 1000),
      memory_interval: Keyword.get(opts, :memory_interval, 1000),
      formatters: Keyword.get(opts, :formatters, []),
      compare?: Keyword.get(opts, :compare?, false),
      output_dir: Keyword.get(opts, :output_dir, temporary_dir(__MODULE__)),
      attached?: Keyword.get(opts, :attached?, false),
      metadata: Keyword.get(opts, :metadata, %{})
    }

    scenario |> Suite.init(config) |> Suite.run()
  end

  @spec html_assets_paths() :: [Path.t()]
  def html_assets_paths() do
    assets_dir = Path.join([Application.app_dir(:beamchmark), "priv", "assets"])

    ["css", "js"]
    |> Enum.flat_map(fn asset_type -> [assets_dir, asset_type, "*.#{asset_type}"] end)
    |> Path.join()
    |> Path.wildcard()
  end
end
