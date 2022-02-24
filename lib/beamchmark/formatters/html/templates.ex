defmodule Beamchmark.Formatters.HTML.Templates do
  @moduledoc false

  require EEx

  alias Beamchmark.Suite.Measurements.SchedulerInfo

  EEx.function_from_file(:def, :index, "priv/templates/index.html.eex", [:new_suite, :base_suite])

  EEx.function_from_file(:def, :configuration, "priv/templates/configuration.html.eex", [
    :configuration
  ])

  EEx.function_from_file(:def, :system, "priv/templates/system.html.eex", [:system_info])

  EEx.function_from_file(:def, :measurements, "priv/templates/measurements.html.eex", [
    :measurements
  ])

  EEx.function_from_file(
    :def,
    :measurements_compare,
    "priv/templates/measurements_compare.html.eex",
    [
      :new_measurements,
      :base_measurements
    ]
  )

  @spec format_scheduler_info(SchedulerInfo.sched_usage_t()) :: %{
          (scheduler_usage_entry :: atom()) => String.t()
        }
  def format_scheduler_info(scheduler_usage_info) do
    sorted_by_ids =
      Enum.sort_by(scheduler_usage_info, fn {scheduler_id, _scheduler_usage} -> scheduler_id end)

    %{
      scheduler_ids:
        Enum.map_join(sorted_by_ids, ", ", fn {scheduler_id, _usage} -> scheduler_id end),
      usage:
        Enum.map_join(sorted_by_ids, ", ", fn {_scheduler_id, {usage, _percent_usage}} ->
          usage
        end),
      percent_usage:
        Enum.map_join(sorted_by_ids, ", ", fn {_scheduler_id, {_usage, percent_usage}} ->
          [percent_usage, "%"]
          |> Enum.join()
          |> format_as_string()
        end)
    }
  end

  @spec format_as_string(String.t()) :: String.t()
  def format_as_string(string), do: Enum.join(['"', string, '"'])

  @spec was_busy?(SchedulerInfo.sched_usage_t()) :: boolean()
  def was_busy?(scheduler_usage_info) do
    Enum.any?(scheduler_usage_info, fn {_scheduler_id, {usage, _percent_usage}} -> usage > 0 end)
  end
end
