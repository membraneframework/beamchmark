defmodule Beamchmark do
  @moduledoc """
  Top level module providing `Beamchmark.run` API.

  `#{inspect(__MODULE__)}` measures EVM performance while it is running user `#{inspect(__MODULE__)}.Scenario`.

  # Metrics being measured

  ## Scheduler Utilization

  At the moment, the main interest of `#{inspect(__MODULE__)}` is scheduler utilization which tells
  how much given scheduler was busy.
  Scheduler is busy when:
  * Executing process code
  * Executing linked-in driver or NIF code
  * Executing BIFs, or any other runtime handling
  * Garbage collecting
  * Handling any other memory management

  Scheduler utilization is measured using Erlang's [`:scheduler`](`:scheduler`) module which uses `:erlang.statistics/1`
  under the hood and it is represented as a floating point value between 0.0 and 1.0 and percent. 

  `#{inspect(__MODULE__)}` measures following types of scheduler utilization:
  * normal/cpu/io - average utilization of single scheduler of given type
  * total normal/cpu/io - average utilization of all schedulers of given type. E.g total normal equals 1.0 when
  each of normal schedulers have been acive all the time
  * total - average utilization of all schedulers
  * weighted - average utilization of all schedulers weighted against maximum amount of available CPU time

  For more information please refer to `:erlang.statistics/1` (under `:scheduler_wall_time`) or `:scheduler.utilization/1`.
  """

  @typedoc """
  Configuration for `#{inspect(__MODULE__)}`.
  * duration - time in seconds `#{inspect(__MODULE__)}` will be benchmarking EVM. Defaults to 60 seconds.
  * delay - time in seconds `#{inspect(__MODULE__)}` will wait after running scenario and befor starting benchmarking.
  * output_dir - directory where results of benchmarking will be saved.
  """
  @type options_t() :: [
          duration: pos_integer(),
          delay: non_neg_integer(),
          output_dir: Path.t()
        ]

  @default_output_dir "benchmark"
  @results_file_name "results"

  @doc """
  Runs scenario and benchmarks EVM performance. 

  Subsequent invocation of this function will also compare results with the previous ones.
  """
  @spec run(Beamchmark.Scenario, options_t()) :: :ok
  def run(scenario, opts) do
    output_dir = opts[:output_dir] || @default_output_dir
    base_dir = Path.join(output_dir, "base")
    new_dir = Path.join(output_dir, "new")

    if File.exists?(new_dir) do
      File.rm_rf!(base_dir)
      File.rename!(new_dir, base_dir)
    end

    Mix.shell().info("Running scenario")
    task = Task.async(fn -> scenario.run() end)
    Process.sleep(opts[:delay] || 0)
    results = bench(opts)
    Task.await(task, :infinity)
    print(results, base_dir)
    save(results, new_dir)
    Mix.shell().info("Results successfully saved to #{inspect(new_dir)} directory")
    :ok
  end

  defp bench(opts) do
    Mix.shell().info("Benching")

    :scheduler.utilization(opts[:duration] || 60)
    |> Beamchmark.SchedulerInfo.from_sched_util_result()
  end

  defp save(results, new_dir) do
    File.mkdir_p!(new_dir)
    out = Path.join(new_dir, @results_file_name)
    results = :erlang.term_to_binary(results)
    File.write!(out, results)
    :ok
  end

  defp print(new, base_dir) do
    print_system_info()

    base =
      if File.exists?(base_dir) do
        Path.join(base_dir, @results_file_name)
        |> File.read!()
        |> :erlang.binary_to_term()
      end

    if base do
      """
      ================
      BASE
      ================
      """
      |> Mix.shell().info()

      Mix.shell().info(format(base))
    end

    diff = if base, do: Beamchmark.SchedulerInfo.scheduler_info_diff(base, new)

    """
    ================
    NEW
    ================
    """
    |> Mix.shell().info()

    Mix.shell().info(format(new, diff))
  end

  defp print_system_info() do
    info = """

    ================
    SYSTEM INFO
    ================

    System version: #{:erlang.system_info(:system_version)}\
    System arch: #{:erlang.system_info(:system_architecture)}
    NIF version: #{:erlang.system_info(:nif_version)}
    """

    Mix.shell().info(info)
  end

  defp format(scheduler_info) do
    format(scheduler_info, nil)
  end

  defp format(scheduler_info, nil) do
    """
    Normal schedulers
    --------------------
    #{format_sched_usage(scheduler_info.normal)} 
    Total: #{format_sched_usage(scheduler_info.total_normal)}

    CPU schedulers
    --------------------
    #{format_sched_usage(scheduler_info.cpu)} 
    Total: #{format_sched_usage(scheduler_info.total_cpu)}

    IO schedulers
    --------------------
    #{format_sched_usage(scheduler_info.io)} 
    Total: #{format_sched_usage(scheduler_info.total_io)}

    Weighted
    --------------------
    #{format_sched_usage(scheduler_info.weighted)}
    """
  end

  defp format(scheduler_info, scheduler_info_diff) do
    """
    Normal schedulers
    --------------------
    #{format_sched_usage(scheduler_info.normal, scheduler_info_diff.normal)} 
    Total: #{format_sched_usage(scheduler_info.total_normal, scheduler_info_diff.total_normal)} 

    CPU schedulers
    --------------------
    #{format_sched_usage(scheduler_info.cpu, scheduler_info_diff.cpu)} 
    Total: #{format_sched_usage(scheduler_info.total_cpu, scheduler_info_diff.total_cpu)}

    IO schedulers
    --------------------
    #{format_sched_usage(scheduler_info.io, scheduler_info_diff.io)} 
    Total: #{format_sched_usage(scheduler_info.total_io, scheduler_info_diff.total_io)}

    Weighted
    --------------------
    #{format_sched_usage(scheduler_info.weighted, scheduler_info_diff.weighted)}
    """
  end

  defp format_sched_usage(sched_usage), do: format_sched_usage(sched_usage, nil)

  defp format_sched_usage(sched_usage, nil) when is_map(sched_usage) do
    Enum.map(sched_usage, fn {sched_id, {util, percent}} ->
      "#{sched_id} #{util} #{percent}%\n"
    end)
  end

  defp format_sched_usage(sched_usage, sched_usage_diff)
       when is_map(sched_usage) and is_map(sched_usage_diff) do
    Enum.map(sched_usage, fn {sched_id, {util, percent}} ->
      {util_diff, percent_diff} = Map.get(sched_usage_diff, sched_id)
      color = get_color(percent_diff)

      "#{sched_id} #{util} #{percent}% #{color} #{util_diff} #{percent_diff}#{if percent_diff != :nan, do: "%"}#{IO.ANSI.reset()}\n"
    end)
  end

  # clauses for total and weighted usage
  defp format_sched_usage({util, percent}, nil) do
    "#{util} #{percent}%\n"
  end

  defp format_sched_usage({util, percent}, {util_diff, percent_diff}) do
    color = get_color(util_diff)

    "#{util} #{percent}% #{color} #{util_diff} #{percent_diff}#{if percent_diff != :nan, do: "%"}#{IO.ANSI.reset()}\n"
  end

  defp get_color(diff) do
    cond do
      diff < 0 -> IO.ANSI.green()
      diff == 0 -> IO.ANSI.white()
      diff > 0 -> IO.ANSI.red()
    end
  end
end
