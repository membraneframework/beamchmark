defmodule MockScenario do
  @moduledoc false

  @behaviour Beamchmark.Scenario

  @impl true
  def run(), do: :noop
end
