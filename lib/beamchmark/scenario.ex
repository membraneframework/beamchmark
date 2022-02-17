defmodule Beamchmark.Scenario do
  @moduledoc """
  Scenario to run during benchmarking
  """
  @type t :: module()

  @callback run() :: :ok
end
