defmodule Beamchmark.Scenario do
  @moduledoc """
  Scenario to run during benchmarking. Defines a behaviour that needs to be adopted by benchmarked modules.
  """

  @typedoc """
  Represents a module implementing `#{inspect(__MODULE__)}` behaviour.
  """
  @type t :: module()

  @doc """
  The function that will be called during benchmarking.
  """
  @callback run() :: :ok | {:error, any()}
end
