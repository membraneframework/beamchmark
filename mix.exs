defmodule Beamchmark.MixProject do
  use Mix.Project

  @version "0.1.1"
  @github_url "https://github.com/membraneframework/beamchmark"

  def project do
    [
      app: :beamchmark,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # hex
      description: "Tool for measuring EVM performance",
      package: package(),

      # docs
      name: "Beamchmark",
      source_url: @github_url,
      homepage_url: "https://membraneframework.org",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools, :eex, :os_mon]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      {:bunch, "~> 1.3.0"},
      {:dialyxir, "~> 1.1.0", only: :dev, runtime: false},
      {:credo, "~> 1.6.1", only: :dev, runtime: false},
      {:ex_doc, "~> 0.26.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => @github_url,
        "Membrane Framework Homepage" => "https://membraneframework.org"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
      source_ref: "v#{@version}",
      nest_modules_by_prefix: [Beamchmark.Suite, Beamchmark.Formatters]
    ]
  end
end
