defmodule Beamchmark.Scenario do
  @moduledoc """
  Scenario to run during benchmarking. Defines a behaviour that needs to be adopted by benchmarked modules.

  `Beamchmark` will call the implementation of `run/0` in a new process, shutting it down once it completes all
  measurements. The implementation should run for a longer period of time (possibly infinite) than measurements,
  so that the EVM isn't benchmarked while it's idle. For the same reason, it is recommended to `raise` immediately
  in case the implementation fails.
  """

  @typedoc """
  Represents a module implementing `#{inspect(__MODULE__)}` behaviour.
  """
  @type t :: module()

  @doc """
  The function that will be called during benchmarking.
  """
  @callback run() :: any()
end
