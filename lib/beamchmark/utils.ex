defmodule Beamchmark.Utils do
  @moduledoc false

  @spec get_color(integer() | float()) :: binary()
  def get_color(diff) do
    cond do
      diff < 0 -> IO.ANSI.green()
      diff == 0 -> IO.ANSI.white()
      diff > 0 -> IO.ANSI.red()
    end
  end
end
