defmodule AdvancedScenario do
  @behaviour Beamchmark.Scenario

  @impl true
  def run() do
    Enum.map(1..100_000_000, fn i -> Integer.pow(i, 2) end)
    :ok
  end
end

Beamchmark.run(AdvancedScenario,
  duration: 10,
  delay: 1,
  compare?: true,
  output_dir: "beamchmark",
  formatters: [
    Beamchmark.Formatters.Console,
    {Beamchmark.Formatters.HTML,
     [output_path: "reports/beamchmark.html", auto_open?: true, inline_assets?: false]}
  ]
)
