defmodule Beamchmark.Scenario do
  @moduledoc """
  Scenario to run during benchmarking. Defines a behaviour that needs to be adopted by benchmarked modules.
  """
  @type t :: module()

  @callback run() :: :ok
end
