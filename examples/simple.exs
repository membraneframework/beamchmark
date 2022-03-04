defmodule SimpleScenario do
  @behaviour Beamchmark.Scenario

  @impl true
  def run() do
    Enum.map(1..1_000_000, fn i -> Integer.pow(i, 2) end)
    :ok
  end
end

Beamchmark.run(SimpleScenario, duration: 5, delay: 1)
