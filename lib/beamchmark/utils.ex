defmodule Beamchmark.Utils do
  @moduledoc """
  The module defines utility functions for Beamchmark.
  """

  @spec os :: :FreeBSD | :Linux | :Windows | :macOS
  def os() do
    {_family, name} = :os.type()

    case name do
      :darwin -> :macOS
      :nt -> :Windows
      :freebsd -> :FreeBSD
      _other -> :Linux
    end
  end
end
