defmodule Beamchmark.Formatters.HTML.Templates do
  @moduledoc false

  require EEx

  alias Beamchmark.Scenario
  alias Beamchmark.Suite.Measurements.SchedulerInfo

  EEx.function_from_file(:def, :index, "priv/templates/index.html.eex", [
    :new_suite,
    :base_suite,
    :inline_assets?
  ])

  EEx.function_from_file(:def, :configuration, "priv/templates/configuration.html.eex", [
    :configuration
  ])

  EEx.function_from_file(:def, :system, "priv/templates/system.html.eex", [:system_info])

  EEx.function_from_file(:def, :measurements, "priv/templates/measurements.html.eex", [
    :new_measurements,
    :base_measurements
  ])

  @spec format_scenario(Scenario.t()) :: String.t()
  def format_scenario(scenario) do
    scenario |> Atom.to_string() |> String.trim_leading("Elixir.")
  end

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
          "\"#{percent_usage}%\""
        end)
    }
  end

  @spec was_busy?(SchedulerInfo.sched_usage_t()) :: boolean()
  def was_busy?(scheduler_usage_info) do
    Enum.any?(scheduler_usage_info, fn {_scheduler_id, {usage, _percent_usage}} -> usage > 0 end)
  end

  @spec as_downcase_atom(String.t()) :: atom()
  def as_downcase_atom(metric), do: metric |> String.downcase() |> String.to_existing_atom()
end
