defmodule Beamchmark do
  @moduledoc """
  Top level module providing `Beamchmark.run/2` and `Beamchmark.run_attached/2` API.

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
  each of normal schedulers have been active all the time
  * total - average utilization of all schedulers
  * weighted - average utilization of all schedulers weighted against maximum amount of available CPU time

  For more information please refer to `:erlang.statistics/1` (under `:scheduler_wall_time`) or `:scheduler.utilization/1`.

  ## Other

  Other metrics being measured:
  * reductions - total reductions number
  * context switches - total context switches number
  """

  alias Beamchmark.Scenario.EmptyScenario
  alias Beamchmark.Suite.Configuration

  @default_configuration %Beamchmark.Suite.Configuration{
    duration: 60,
    cpu_interval: 1000,
    memory_interval: 1000,
    delay: 0,
    formatters: [Beamchmark.Formatters.Console],
    output_dir: Path.join([System.tmp_dir!(), "beamchmark"]),
    compare?: true,
    attached?: false,
    custom_configuration: %{}
  }

  @typedoc """
  Configuration for `#{inspect(__MODULE__)}`.
  * `name` - name of the benchmark. It can be used by formatters.
  * `duration` - time in seconds `#{inspect(__MODULE__)}` will be benchmarking EVM. Defaults to `#{@default_configuration.duration}` seconds.
  * `cpu_interval` - time in milliseconds `#{inspect(__MODULE__)}` will be benchmarking cpu usage. Defaults to `#{@default_configuration.cpu_interval}` milliseconds. Needs to be greater than or equal to `interfere_timeout`.
  * `memory_interval` - time in milliseconds `#{inspect(__MODULE__)}` will be benchmarking memory usage. Defaults to `#{@default_configuration.memory_interval}` milliseconds. Needs to be greater than or equal to `interfere_timeout`.
  * `delay` - time in seconds `#{inspect(__MODULE__)}` will wait after running scenario and before starting benchmarking. Defaults to `#{@default_configuration.delay}` seconds.
  * `formatters` - list of formatters that will be applied to the result. By default contains only `#{inspect(@default_configuration.formatters)}`.
  * `compare?` - boolean indicating whether formatters should compare results for given scenario with the previous one. Defaults to `#{inspect(@default_configuration.compare?)}.`
  * `output_dir` - directory where results of benchmarking will be saved. Defaults to "`beamchmark`" directory under location provided by `System.tmp_dir!/0`.
  """
  @type options_t() :: [
          name: String.t(),
          duration: pos_integer(),
          cpu_interval: pos_integer(),
          memory_interval: pos_integer(),
          delay: non_neg_integer(),
          formatters: [Beamchmark.Formatter.t()],
          compare?: boolean(),
          output_dir: Path.t()
        ]

  @doc """
  Runs scenario and benchmarks EVM performance.

  If `compare?` option equals `true`, invocation of this function will also compare new measurements with the last ones.
  Measurements will be compared only if they share the same scenario module, delay and duration.
  """
  @spec run(Beamchmark.Scenario.t(), options_t()) :: :ok
  def run(scenario, opts \\ []) do
    config = Configuration.get_configuration(opts, @default_configuration)

    scenario
    |> Beamchmark.Suite.init(config)
    |> Beamchmark.Suite.run()
    |> tap(fn suite -> :ok = Beamchmark.Suite.save(suite) end)
    |> tap(fn suite -> :ok = Beamchmark.Formatter.output(suite) end)

    :ok
  end

  @doc """
  Executes `Beamchmark.run/2` on a given node.

  This function can be used to measure performance of an already running node.
  The node which we are connecting to has to be a distributed node.
  """
  @spec run_attached(node(), options_t()) :: :ok
  def run_attached(node_name, opts \\ []) do
    Node.start(:beamchmark@localhost, :shortnames)

    unless Node.connect(node_name) == true do
      raise "Failed to connect to #{node_name} or the node is not alive."
    end

    pid = Node.spawn(node_name, __MODULE__, :run, [EmptyScenario, opts ++ [attached?: true]])
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, _process, _object, _reason} ->
        :ok
    end
  end
end
