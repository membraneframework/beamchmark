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
end
