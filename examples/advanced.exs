defmodule AdvancedScenario do
  @behaviour Beamchmark.Scenario

  def run_and_print() do
    IO.inspect(:cpu_sup.util([:per_cpu]))
    Process.sleep(100)
    run_and_print()
  end

  @impl true
  def run() do
    Enum.map(1..1_000_000, fn i -> Integer.pow(i, 2) end)
    :ok
  end
end

Beamchmark.run(AdvancedScenario, duration: 10, delay: 1, formatters: [Beamchmark.Formatters.HTML])
