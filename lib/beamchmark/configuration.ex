defmodule Beamchmark.Configuration do
  @moduledoc false

  alias Beamchmark.Formatter

  @type t :: %__MODULE__{
          duration: pos_integer(),
          delay: non_neg_integer(),
          formatters: [Formatter.t()],
          output_dir: Path.t(),
          try_compare?: boolean()
        }

  @enforce_keys [:duration, :delay, :formatters, :try_compare?, :output_dir]
  defstruct @enforce_keys
end
