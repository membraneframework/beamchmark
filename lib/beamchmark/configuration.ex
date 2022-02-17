defmodule Beamchmark.Configuration do
  @moduledoc false

  alias Beamchmark.Formatter

  @type t :: %__MODULE__{
          formatters: [Formatter.t()],
          delay: non_neg_integer(),
          duration: pos_integer(),
          output_dir: Path.t(),
          try_compare?: boolean()
        }

  @enforce_keys [:delay, :duration, :formatters, :output_dir, :try_compare?]
  defstruct @enforce_keys
end
