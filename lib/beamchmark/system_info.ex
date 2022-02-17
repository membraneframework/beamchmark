defmodule Beamchmark.SystemInfo do
  @moduledoc false

  @type t :: %__MODULE__{
          elixir_version: String.t(),
          otp_version: String.t(),
          nif_version: String.t(),
          os: atom(),
          arch: String.t(),
          num_cores: pos_integer()
        }

  @enforce_keys [:elixir_version, :otp_version, :nif_version, :os, :arch, :num_cores]
  defstruct @enforce_keys

  @spec init :: Beamchmark.SystemInfo.t()
  def init() do
    %__MODULE__{
      elixir_version: System.version(),
      otp_version: :erlang.system_info(:otp_release) |> List.to_string(),
      nif_version: :erlang.system_info(:nif_version) |> List.to_string(),
      os: os(),
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
end
