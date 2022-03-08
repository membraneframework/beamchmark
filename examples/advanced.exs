defmodule AdvancedScenario do
  @behaviour Beamchmark.Scenario

  @out_dir __MODULE__ |> Atom.to_string() |> String.trim_leading("Elixir.")
  @num_schedulers System.schedulers_online()
  @functions [
    &:math.sqrt/1,
    &:math.sin/1,
    &:math.cos/1,
    &:math.tan/1,
    &:math.log/1,
    &:math.log2/1,
    &:math.log10/1,
    &:math.erf/1
  ]

  @impl true
  def run() do
    File.mkdir_p!(@out_dir)

    @functions
    |> Stream.cycle()
    |> Stream.take(@num_schedulers)
    |> Task.async_stream(
      fn function ->
        {:name, name} = Function.info(function, :name)
        filename = Atom.to_string(name) <> ".txt"
        out_path = Path.join([@out_dir, filename])

        1..10_000_000
        |> Enum.map_join("\n", &function.(&1))
        |> then(&File.write!(out_path, &1))
      end,
      ordered: false,
      timeout: :infinity
    )
    |> Stream.run()
  end
end

Beamchmark.run(AdvancedScenario,
  duration: 15,
  delay: 5,
  compare?: true,
  output_dir: "beamchmark_output",
  formatters: [
    Beamchmark.Formatters.Console,
    {Beamchmark.Formatters.HTML,
     [output_path: "reports/beamchmark.html", auto_open?: true, inline_assets?: false]}
  ]
)
