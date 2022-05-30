defmodule Beamchmark.Suite.Configuration do
  @moduledoc """
  The module defines a structure used to configure `#{inspect(Beamchmark.Suite)}`. For more information
  about customizing #{inspect(Beamchmark)}, refer to `t:Beamchmark.options_t/0`.
  """

  alias Beamchmark.Formatter

  @type t :: %__MODULE__{
          name: String.t() | nil,
          duration: pos_integer(),
          cpu_interval: pos_integer(),
          delay: non_neg_integer(),
          formatters: [Formatter.t()],
          output_dir: Path.t(),
          compare?: boolean()
        }

  @enforce_keys [:duration, :cpu_interval, :delay, :formatters, :compare?, :output_dir]
  defstruct @enforce_keys ++ [:name]

  @spec get_configuration(Keyword.t(), __MODULE__.t()) :: __MODULE__.t()
  def get_configuration(opts, default_config) do
    %Beamchmark.Suite.Configuration{
      name: Keyword.get(opts, :name),
      duration: Keyword.get(opts, :duration, default_config.duration),
      cpu_interval: Keyword.get(opts, :cpu_interval, default_config.cpu_interval),
      delay: Keyword.get(opts, :delay, default_config.delay),
      formatters: Keyword.get(opts, :formatters, default_config.formatters),
      compare?: Keyword.get(opts, :compare?, default_config.compare?),
      output_dir: Keyword.get(opts, :output_dir, default_config.output_dir) |> Path.expand()
    }
  end
end
