defmodule Beamchmark.Formatters.Console do
  @moduledoc """
  The module formats `#{inspect(Beamchmark.Suite)}` and outputs it using `Mix.shell/0`.
  """

  @behaviour Beamchmark.Formatter

  alias Beamchmark.Formatters.Utils
  alias Beamchmark.Suite.{Configuration, Measurements, SystemInfo}
  alias Beamchmark.{Math, Suite}

  @precision 2

  @impl true
  def format(%Suite{} = suite, _options) do
    benchmark_name = suite.configuration.name
    system_info = format_system_info(suite.system_info)
    configuration = format_configuration(suite.configuration)
    measurements = format_measurements(suite.measurements)

    [benchmark_name, system_info, configuration, measurements]
    |> Enum.join("\n")
  end

  @impl true
  def format(%Suite{} = new_suite, %Suite{} = base_suite, _options) do
    benchmark_name = new_suite.configuration.name
    system_info = format_system_info(new_suite.system_info)
    configuration = format_configuration(new_suite.configuration)
    base_measurements = format_measurements(base_suite.measurements)
    diff_measurements = Measurements.diff(base_suite.measurements, new_suite.measurements)
    new_measurements = format_measurements(new_suite.measurements, diff_measurements)

    [benchmark_name, system_info, configuration, base_measurements, new_measurements]
    |> Enum.join("\n")
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
    Memory: #{Utils.format_memory(system_info.mem)}
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
    #{format_numbers(measurements.cpu_info.average_all)}%

    #{entry_header("CPU Usage Per Core")}
    #{format_cpu_by_core(measurements.cpu_info.average_by_core)}

    #{entry_header("Memory usage")}
    #{format_numbers(measurements.memory_info.average.total)}
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
    #{format_cpu_average(measurements.cpu_info.average_all,
    measurements_diff.cpu_info.average_all)}

    #{entry_header("CPU Usage Per Core")}
    #{format_cpu_by_core(measurements.cpu_info.average_by_core,
    measurements_diff.cpu_info.average_by_core)}

    #{entry_header("Memory usage")}
    #{format_memory_average(measurements.memory_info.average.total, measurements_diff.memory_info.average.total)}
    """
  end

  defp format_cpu_average(cpu_average, cpu_average_diff) do
    cpu_old = cpu_average - cpu_average_diff

    cpu_diff_percent = Math.percent_diff(cpu_old, cpu_average)
    color = get_color(cpu_average_diff)

    "#{format_numbers(cpu_average)}% #{color} #{format_numbers(cpu_average_diff)}% #{format_numbers(cpu_diff_percent)}#{if cpu_diff_percent != :nan, do: "%"}#{IO.ANSI.reset()}"
  end

  defp format_memory_average(memory_average, memory_average_diff) do
    memory_old = memory_average - memory_average_diff

    memory_diff_percent = Math.percent_diff(memory_old, memory_average)
    color = get_color(memory_average_diff)

    "#{Utils.format_memory(memory_average)} #{color} #{Utils.format_memory(memory_average_diff)} #{format_numbers(memory_diff_percent)}#{if memory_diff_percent != :nan, do: "%"}#{IO.ANSI.reset()}"
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

  defp format_cpu_by_core(cpu_by_core) do
    Enum.map_join(cpu_by_core, "\n", fn {core_id, usage} ->
      "Core: #{core_id} -> #{format_numbers(usage)} %"
    end)
  end

  defp format_cpu_by_core(cpu_by_core, cpu_by_core_diff) do
    Enum.map_join(cpu_by_core, "\n", fn {core_id, usage} ->
      usage_diff = Map.get(cpu_by_core_diff, core_id)
      usage_old = usage - usage_diff
      usage_diff_percent = Math.percent_diff(usage_old, usage)
      color = get_color(usage_diff)

      "Core #{core_id} -> #{format_numbers(usage)}% #{color} #{format_numbers(usage_diff)} #{format_numbers(usage_diff_percent)} #{if usage_diff_percent != :nan, do: "%"}#{IO.ANSI.reset()}"
    end)
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

  defp format_numbers(number) when is_integer(number) or number == :nan, do: "#{number}"

  defp format_numbers(float_value) when is_float(float_value) do
    Float.round(float_value, @precision)
  end

  defp format_numbers(number, number_diff) when is_integer(number) and is_integer(number_diff) do
    color = get_color(number_diff)
    # old number = number - number_diff
    percent_diff = Math.percent_diff(number - number_diff, number)

    "#{number} #{color} #{number_diff} #{percent_diff}#{if percent_diff != :nan, do: "%"}#{IO.ANSI.reset()}"
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
