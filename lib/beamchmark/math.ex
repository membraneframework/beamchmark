defmodule Beamchmark.Math do
  @moduledoc """
  The module contains math utility functions.
  """

  @typedoc """
  Represents a percent.
  """
  @type percent_t() :: float()

  @typedoc """
  Represents a percent difference.

  This can be either `t:percent_t/0` or `:nan` when trying to compare value with 0.
  """
  @type percent_diff_t() :: percent_t() | :nan

  @spec percent_diff(number(), number()) :: percent_diff_t()
  def percent_diff(base, new) do
    cond do
      base == new ->
        # if both values are the same return 0, in other case check against nan
        0

      base == 0 ->
        # cannot count when base is 0
        :nan

      new == 0 ->
        # new value is 100% lower than the base one
        -100

      true ->
        new / base * 100 - 100
    end
  end
end
