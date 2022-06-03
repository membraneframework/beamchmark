defmodule Beamchmark.Scenario.EmptyScenario do
  @moduledoc false

  @behaviour Beamchmark.Scenario

  @spec run() :: :ok
  def run() do
    :ok
  end
end
