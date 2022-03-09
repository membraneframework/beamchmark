defmodule Beamchmark.Formatters.Console do
  @moduledoc """
  The module formats `#{inspect(Beamchmark.Suite)}` and outputs it using `Mix.shell/0`.
  """

  @behaviour Beamchmark.Formatter

  alias Beamchmark.{Suite, Math}
  alias Beamchmark.Suite.{Configuration, Measurements, SystemInfo}

  @impl true
  def format(%Suite{} = suite, _options) do
    system_info = format_system_info(suite.system_info)
    configuration = format_configuration(suite.configuration)
    measurements = format_measurements(suite.measurements)
    Enum.join([system_info, configuration, measurements], "\n")
  end

  @impl true
  def format(%Suite{} = new_suite, %Suite{} = base_suite, _options) do
    system_info = format_system_info(new_suite.system_info)
    configuration = format_configuration(new_suite.configuration)
    base_measurements = format_measurements(base_suite.measurements)
    diff_measurements = Measurements.diff(base_suite.measurements, new_suite.measurements)
    new_measurements = format_measurements(new_suite.measurements, diff_measurements)

    Enum.join([system_info, configuration, base_measurements, new_measurements], "\n")
  end

  @impl true
  def write(data, _options) do
    Mix.shell().info(data)
  end

  defp format_system_info(%SystemInfo{} = system_info) do
    """
    #{section_header("System info")}

    Elixir version: #{system_info.elixir_version}
    OTP version: #{system_info.otp_version}
    OS: #{system_info.os}
    System arch: #{system_info.arch}
    NIF version: #{system_info.nif_version}
    Cores: #{system_info.num_cores}
    """
  end

  defp format_configuration(%Configuration{} = configuration) do
    """
    #{section_header("Configuration")}

    Delay: #{inspect(configuration.delay)}s
    Duration: #{inspect(configuration.duration)}s
    """
  end

  defp format_measurements(%Measurements{} = measurements) do
    """
    #{section_header("Measurements")}

    #{format_scheduler_info(measurements.scheduler_info)}

    #{entry_header("Reductions")}
    #{format_numbers(measurements.reductions)}

    #{entry_header("Context Switches")}
    #{format_numbers(measurements.context_switches)}

    #{entry_header("CPU Usage Average")}
    #{measurements.cpu_info.average_all |> convert_float_to_percent(2)}%
    """
  end

  defp format_measurements(%Measurements{} = measurements, %Measurements{} = measurements_diff) do
    """
    #{section_header("New measurements")}

    #{format_scheduler_info(measurements.scheduler_info, measurements_diff.scheduler_info)}

    #{entry_header("Reductions")}
    #{format_numbers(measurements.reductions, measurements_diff.reductions)}

    #{entry_header("Context Switches")}
    #{format_numbers(measurements.context_switches,
    measurements_diff.context_switches)}

    #{entry_header("CPU Usage Average")}
    #{format_percent_diff(measurements.cpu_info.average_all,
    measurements_diff.cpu_info.average_all)}
    """
  end

  defp format_scheduler_info(%Measurements.SchedulerInfo{} = scheduler_info) do
    """
    #{entry_header("Normal schedulers")}
    #{format_scheduler_entry(scheduler_info.normal)}
    Total: #{format_scheduler_entry(scheduler_info.total_normal)}

    #{entry_header("CPU schedulers")}
    #{format_scheduler_entry(scheduler_info.cpu)}
    Total: #{format_scheduler_entry(scheduler_info.total_cpu)}

    #{entry_header("IO schedulers")}
    #{format_scheduler_entry(scheduler_info.io)}
    Total: #{format_scheduler_entry(scheduler_info.total_io)}

    #{entry_header("Weighted")}
    #{format_scheduler_entry(scheduler_info.weighted)}
    """
  end

  defp format_scheduler_info(
         %Measurements.SchedulerInfo{} = scheduler_info,
         %Measurements.SchedulerInfo{} = scheduler_info_diff
       ) do
    """
    #{entry_header("Normal schedulers")}
    #{format_scheduler_entry(scheduler_info.normal, scheduler_info_diff.normal)}
    Total: #{format_scheduler_entry(scheduler_info.total_normal, scheduler_info_diff.total_normal)}

    #{entry_header("CPU schedulers")}
    #{format_scheduler_entry(scheduler_info.cpu, scheduler_info_diff.cpu)}
    Total: #{format_scheduler_entry(scheduler_info.total_cpu, scheduler_info_diff.total_cpu)}

    #{entry_header("IO schedulers")}
    #{format_scheduler_entry(scheduler_info.io, scheduler_info_diff.io)}
    Total: #{format_scheduler_entry(scheduler_info.total_io, scheduler_info_diff.total_io)}

    #{entry_header("Weighted")}
    #{format_scheduler_entry(scheduler_info.weighted, scheduler_info_diff.weighted)}
    """
  end

  defp format_scheduler_entry(sched_usage) when is_map(sched_usage) do
    Enum.map_join(sched_usage, "\n", fn {sched_id, {util, percent}} ->
      "#{sched_id} #{util} #{percent}%"
    end)
  end

  # clauses for total and weighted usage
  defp format_scheduler_entry({util, percent}) do
    "#{util} #{percent}%"
  end

  defp convert_float_to_percent(float, percision) do
    float |> Float.round(percision)
  end

  defp format_scheduler_entry(sched_usage, sched_usage_diff)
       when is_map(sched_usage) and is_map(sched_usage_diff) do
    Enum.map_join(sched_usage, "\n", fn {sched_id, {util, percent}} ->
      {util_diff, percent_diff} = Map.get(sched_usage_diff, sched_id)
      color = get_color(percent_diff)

      "#{sched_id} #{util} #{percent}% #{color} #{util_diff} #{percent_diff}#{if percent_diff != :nan, do: "%"}#{IO.ANSI.reset()}"
    end)
  end

  defp format_scheduler_entry({util, percent}, {util_diff, percent_diff}) do
    color = get_color(util_diff)

    "#{util} #{percent}% #{color} #{util_diff} #{percent_diff}#{if percent_diff != :nan, do: "%"}#{IO.ANSI.reset()}"
  end

  defp format_numbers(number) when is_integer(number), do: "#{number}"

  defp format_numbers(number, number_diff) when is_integer(number) and is_integer(number_diff) do
    color = get_color(number_diff)
    # old number = number - number_diff
    percent_diff = Math.percent_diff(number - number_diff, number)

    "#{number} #{color} #{number_diff} #{percent_diff}#{if percent_diff != :nan, do: "%"}#{IO.ANSI.reset()}"
  end

  defp format_percent_diff(percent, percent_diff) do
    color = get_color(percent_diff)
    percent_diff = Math.percent_diff(percent - percent_diff, percent)

    "#{percent}% #{color} #{percent_diff}#{if percent_diff != :nan, do: "%"}#{IO.ANSI.reset()}"
  end

  defp section_header(text) do
    """
    ================
    #{String.upcase(text)}
    ================
    """
    |> String.trim()
  end

  defp entry_header(text) do
    """
    #{text}
    --------------------
    """
    |> String.trim()
  end

  defp get_color(diff) do
    cond do
      diff < 0 -> IO.ANSI.green()
      diff == 0 -> IO.ANSI.white()
      diff > 0 -> IO.ANSI.red()
    end
  end
end
