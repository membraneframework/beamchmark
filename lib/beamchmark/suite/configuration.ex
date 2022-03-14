defmodule Beamchmark.Suite.Configuration do
  @moduledoc """
  The module defines a structure used to configure `#{inspect(Beamchmark.Suite)}`. For more information
  about customizing #{inspect(Beamchmark)}, refer to `t:Beamchmark.options_t/0`.
  """

  alias Beamchmark.Formatter

  @type t :: %__MODULE__{
          duration: pos_integer(),
          interval: pos_integer() | nil,
          delay: non_neg_integer(),
          formatters: [Formatter.t()],
          output_dir: Path.t(),
          compare?: boolean()
        }

  @enforce_keys [:duration, :delay, :formatters, :compare?, :output_dir]
  defstruct [:duration, :interval, :delay, :formatters, :compare?, :output_dir]
end
