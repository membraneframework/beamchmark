defmodule AdvancedScenario do
  @behaviour Beamchmark.Scenario

  def run_and_print() do
   IO.inspect :cpu_sup.util([:per_cpu])
   Process.sleep(100)
   run_and_print()
  end

  @impl true
  def run() do
    Enum.map(1..1_000_000, fn i -> Integer.pow(i, 2) end)
    :ok
  end
end

# :cpu_sup.start()
# task1 = Task.async(fn -> Beamchmark.run(AdvancedScenario, [duration: 10, delay: 1, formatters: [Beamchmark.Formatters.HTML]]) end)
# IO.puts("Sleeping for some time")
# Process.sleep(2000)
# IO.puts("Awaiking")
# task = Task.async(fn ->
#   AdvancedScenario.run_and_print()
#   end)
# Task.await(task1,100000)
# Task.shutdown(task)
# Process.sleep(1000)
# IO.inspect :cpu_sup.util([:per_cpu])

 Beamchmark.run(AdvancedScenario, [duration: 10, delay: 1, formatters: [Beamchmark.Formatters.HTML]])
