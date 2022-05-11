defmodule Beamchmark.Suite.SystemInfo do
  @moduledoc """
  The module defines a struct containing various information about system that is used for benchmarking.
  """

  @type t :: %__MODULE__{
          elixir_version: String.t(),
          otp_version: String.t(),
          nif_version: String.t(),
          os: atom(),
          mem: pos_integer() | :unknown,
          arch: String.t(),
          num_cores: pos_integer()
        }

  @enforce_keys [:elixir_version, :otp_version, :nif_version, :os, :mem, :arch, :num_cores]
  defstruct @enforce_keys

  @spec init :: t()
  def init() do
    %__MODULE__{
      elixir_version: System.version(),
      otp_version: :erlang.system_info(:otp_release) |> List.to_string(),
      nif_version: :erlang.system_info(:nif_version) |> List.to_string(),
      os: os(),
      mem: mem(os()),
      arch: :erlang.system_info(:system_architecture) |> List.to_string(),
      num_cores: System.schedulers_online()
    }
  end

  defp os() do
    {_family, name} = :os.type()

    case name do
      :darwin -> :macOS
      :nt -> :Windows
      :freebsd -> :FreeBSD
      _other -> :Linux
    end
  end

  @spec mem(atom()) :: pos_integer() | :unknown
  defp mem(:macOS) do
    System.cmd("sysctl", ["-n", "hw.memsize"])
    |> elem(0)
    |> String.trim()
    |> String.to_integer()
  end

  defp mem(:Linux) do
    System.cmd("awk", ["/MemTotal/ {print $2}", "/proc/meminfo"])
    |> elem(0)
    |> String.trim()
    |> String.to_integer()
    |> Kernel.*(1024)
  end

  defp mem(_os) do
    :unknown
  end
end
