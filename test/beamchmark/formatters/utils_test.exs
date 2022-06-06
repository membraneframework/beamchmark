defmodule Beamchmark.Formatters.UtilsTest do
  use ExUnit.Case, async: true

  alias Beamchmark.Formatters.Utils

  describe "Formatters Utils" do
    test "format_memory/2 returns a string" do
      assert is_binary(Utils.format_memory(12_345))
    end

    test "format_memory/2 returns unknown when memory is unknown" do
      assert Utils.format_memory(:unknown) == "-"
    end

    test "format_memory/2 returns human-readable memory size" do
      assert Utils.format_memory(1) == "1 B"
      assert Utils.format_memory(1023) == "1023 B"
      assert Utils.format_memory(1024) == "1 KB"
      assert Utils.format_memory(131_071) == "128 KB"
      assert Utils.format_memory(30_886_854) == "29 MB"
      assert Utils.format_memory(9_079_560_863) == "8 GB"
      assert Utils.format_memory(374_151_781_024) == "348 GB"
    end

    test "format_memory/2 rounds correctly" do
      assert Utils.format_memory(8386, 3) == "8.189 KB"
      assert Utils.format_memory(19_650, 3) == "19.189 KB"
      assert Utils.format_memory(372_107_998, 1) == "354.9 MB"
      assert Utils.format_memory(372_107_998, 3) == "354.87 MB"
      assert Utils.format_memory(372_107_998, 5) == "354.86984 MB"
    end
  end
end
