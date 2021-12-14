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

  ## Other

  Other metrics being measured:
  * reductions - total reductions number
  * context switches - total context switches number
  """

  @typedoc """
  Configuration for `#{inspect(__MODULE__)}`.
  * duration - time in seconds `#{inspect(__MODULE__)}` will be benchmarking EVM. Defaults to 60 seconds.
  * delay - time in seconds `#{inspect(__MODULE__)}` will wait after running scenario and before starting benchmarking.
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
    delay = :timer.seconds(opts[:delay] || 0)
    duration = opts[:duration] || 60
    output_dir = opts[:output_dir] || @default_output_dir
    base_dir = Path.join(output_dir, "base")
    new_dir = Path.join(output_dir, "new")

    if File.exists?(new_dir) do
      File.rm_rf!(base_dir)
      File.rename!(new_dir, base_dir)
    end

    Mix.shell().info("Running scenario")
    task = Task.async(fn -> scenario.run() end)

    Mix.shell().info("Waiting #{inspect(delay)} seconds")
    Process.sleep(delay)

    results = bench(duration)
    Task.await(task, :infinity)

    print(results, base_dir)
    save(results, new_dir)
    :ok
  end

  defp bench(duration) do
    Mix.shell().info("Benchmarking")
    Beamchmark.BEAMInfo.gather(duration)
  end

  defp save(results, new_dir) do
    File.mkdir_p!(new_dir)
    out = Path.join(new_dir, @results_file_name)
    results = :erlang.term_to_binary(results)
    File.write!(out, results)
    Mix.shell().info("Results successfully saved to #{inspect(new_dir)} directory")
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

      Mix.shell().info(Beamchmark.BEAMInfo.format(base))
    end

    diff = if base, do: Beamchmark.BEAMInfo.diff(base, new)

    """
    ================
    NEW
    ================
    """
    |> Mix.shell().info()

    Mix.shell().info(Beamchmark.BEAMInfo.format(new, diff))
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
end
