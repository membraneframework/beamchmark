defmodule Beamchmark.UtilsTest do
  use ExUnit.Case, async: true

  alias Beamchmark.Utils

  describe "Test get_random_node_name" do
    test "get_random_node_name/1 returns correct node name" do
      assert Utils.get_random_node_name(5)
             |> Atom.to_string()
             |> String.match?(~r/^beamchmark[[:digit:]]{5}@localhost$/) == true

      assert Utils.get_random_node_name(11)
             |> Atom.to_string()
             |> String.match?(~r/^beamchmark[[:digit:]]{11}@localhost$/) == true
    end
  end
end
