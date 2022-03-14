defmodule SimpleScenario do
  @moduledoc false

  @behaviour Beamchmark.Scenario

  @impl true
  def run() do
    1..1_000
    |> Stream.cycle()
    |> Stream.each(fn i -> Integer.pow(i, 2) end)
  end
end

Beamchmark.run(SimpleScenario, duration: 5, delay: 1, interval: 500)
