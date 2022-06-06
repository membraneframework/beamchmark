defmodule Beamchmark.Formatters.Utils do
  @moduledoc """
  The module provides functions common for multiple formatters.
  """

  @doc """
  Takes memory in bytes and returns it as human-readable string.
  """
  @spec format_memory(integer() | :unknown, non_neg_integer()) :: String.t()
  def format_memory(mem, decimal_places \\ 0)

  def format_memory(mem, decimal_places) when is_integer(mem) and mem > 0 do
    log_mem = Math.log(mem, 1024)

    div_and_round = fn num, power ->
      (num / Math.pow(1024, power))
      |> Float.round(decimal_places)
      |> (&if(round(&1) == &1, do: round(&1), else: &1)).()
      |> to_string()
    end

    cond do
      log_mem >= 4 -> div_and_round.(mem, 4) <> " TB"
      log_mem >= 3 -> div_and_round.(mem, 3) <> " GB"
      log_mem >= 2 -> div_and_round.(mem, 2) <> " MB"
      log_mem >= 1 -> div_and_round.(mem, 1) <> " KB"
      true -> "#{mem} B"
    end
  end

  def format_memory(mem, _dp) when is_integer(mem) and mem < 0 do
    "-" <> format_memory(-mem)
  end

  def format_memory(0, _dp) do
    "-"
  end

  def format_memory(:unknown, _dp) do
    "-"
  end
end
