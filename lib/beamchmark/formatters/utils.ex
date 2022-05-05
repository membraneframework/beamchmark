defmodule Beamchmark.Formatters.Utils do
  @moduledoc """
  The module provides functions common for multiple formatters.
  """

  @doc """
  Takes memory in bytes and returns it as human-readable string.
  """
  @spec format_memory(non_neg_integer()) :: String.t()
  def format_memory(mem) when is_integer(mem) do
    log_mem = Math.log(mem, 1024)

    cond do
      log_mem >= 3 -> "#{div(mem, Math.pow(1024, 3))} GB"
      log_mem >= 2 -> "#{div(mem, Math.pow(1024, 2))} MB"
      log_mem >= 1 -> "#{div(mem, Math.pow(1024, 1))} KB"
      true -> "#{mem} B"
    end
  end

  def format_memory(:unknown) do
    "-"
  end
end
