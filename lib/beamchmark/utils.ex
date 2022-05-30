defmodule Beamchmark.Utils do
  @moduledoc """
  The module defines utility functions for Beamchmark.
  """

  @spec get_os_name :: :FreeBSD | :Linux | :Windows | :macOS
  def get_os_name() do
    {_family, name} = :os.type()

    case name do
      :darwin -> :macOS
      :nt -> :Windows
      :freebsd -> :FreeBSD
      _other -> :Linux
    end
  end

  @spec get_random_node_name(non_neg_integer()) :: atom()
  def get_random_node_name(length) do
    random_digits =
      Enum.reduce(1..length, [], fn _i, acc ->
        [Enum.random(1..9) | acc]
      end)
      |> Enum.join("")

    ("beamchmark" <> random_digits <> "@localhost") |> String.to_atom()
  end
end
