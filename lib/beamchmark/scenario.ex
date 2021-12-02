defmodule Beamchmark.Scenario do
  @moduledoc """
  Scenario to run during benchmarking
  """

  @callback run() :: :ok
end
