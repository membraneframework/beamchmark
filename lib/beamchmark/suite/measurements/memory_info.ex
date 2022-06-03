defmodule Beamchmark.Suite.Measurements.MemoryInfo do
  @moduledoc """

  """

  @type bytes_t :: non_neg_integer

  @type memory_snapshot_t :: %{
          total: bytes_t,
          processes: bytes_t,
          processes_used: bytes_t,
          system: bytes_t,
          atom: bytes_t,
          atom_used: bytes_t,
          binary: bytes_t,
          code: bytes_t,
          ets: bytes_t
        }

  @type t :: %__MODULE__{
          memory_snapshots: [memory_snapshot_t()],
          average: memory_snapshot_t()
        }

  @enforce_keys [:memory_snapshots, :average]

  defstruct memory_snapshots: [],
            average: %{}

  @spec from_memory_snapshots([memory_snapshot_t()]) :: __MODULE__.t()
  def from_memory_snapshots(memory_snapshots) do
    mem_types = memory_snapshots |> List.first() |> Map.keys()

    average =
      Enum.reduce(mem_types, %{}, fn mem_type, average ->
        mem_type_avg =
          Enum.reduce(memory_snapshots, 0, fn snapshot, sum ->
            sum + Map.get(snapshot, mem_type)
          end)
          |> div(length(memory_snapshots))

        Map.put(average, mem_type, mem_type_avg)
      end)

    %__MODULE__{memory_snapshots: memory_snapshots, average: average}
  end
end
