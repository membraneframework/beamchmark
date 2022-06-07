defmodule Attached do
  @moduledoc false
  @startvalue 10000

  def count(number \\ @startvalue)

  def count(0) do
    count(@startvalue)
  end

  def count(number) do
    Integer.pow(number, number)
    count(number - 1)
  end
end
