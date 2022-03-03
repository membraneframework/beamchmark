defmodule ValidFormatter do
  @moduledoc false

  @behaviour Beamchmark.Formatter

  @impl true
  def format(_new_suite, _base_suite \\ nil, _options), do: :ok

  @impl true
  def write(_data, _options), do: :ok
end
