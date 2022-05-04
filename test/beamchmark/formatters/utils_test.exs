defmodule Beamchmark.Formatters.UtilsTest do
  use ExUnit.Case, async: true

  alias Beamchmark.Formatters.Utils

  describe "Formatters Utils" do
    test "format_memory/1 returns a string" do
      assert is_binary(Utils.format_memory(12_345))
    end

    test "format_memory/1 returns unknown when memory is 0" do
      assert Utils.format_memory(0) == "-"
    end

    test "format_memory/1 returns human-readable memory size" do
      assert Utils.format_memory(1) == "1 B"
      assert Utils.format_memory(1023) == "1023 B"
      assert Utils.format_memory(1024) == "1 KB"
      assert Utils.format_memory(131_071) == "127 KB"
      assert Utils.format_memory(30_886_854) == "29 MB"
      assert Utils.format_memory(9_079_560_863) == "8 GB"
      assert Utils.format_memory(374_151_781_024) == "348 GB"
    end
  end
end
