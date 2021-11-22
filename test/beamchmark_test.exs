defmodule BeamchmarkTest do
  use ExUnit.Case
  doctest Beamchmark

  test "greets the world" do
    assert Beamchmark.hello() == :world
  end
end
