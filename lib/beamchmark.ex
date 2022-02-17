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

  @default_duration 60
  @default_delay 0
  @default_formatters [Beamchmark.Formatters.Console]
  @default_output_dir "/tmp/beamchmark"

  @typedoc """
  Configuration for `#{inspect(__MODULE__)}`.
  * duration - time in seconds `#{inspect(__MODULE__)}` will be benchmarking EVM. Defaults to `#{@default_duration}` seconds.
  * delay - time in seconds `#{inspect(__MODULE__)}` will wait after running scenario and before starting benchmarking. Defaults to `#{@default_delay}` seconds.
  * formatters - list of formatters that will be applied to the result. Defaults to `#{inspect(@default_formatters)}`
  * output_dir - directory where results of benchmarking will be saved. Defaults to `#{@default_output_dir}`.
  """
  @type options_t() :: [
          duration: pos_integer(),
          delay: non_neg_integer(),
          formatters: [Beamchmark.Formatter.t()],
          output_dir: Path.t()
        ]

  @doc """
  Runs scenario and benchmarks EVM performance.

  Subsequent invocation of this function will also compare results with the previous ones.
  """
  @spec run(Scenario.t(), options_t()) :: :ok | {:error, String.t()}
  def run(scenario, opts) do
    config = %Beamchmark.Configuration{
      delay: opts[:delay] || @default_delay,
      duration: opts[:duration] || @default_duration,
      formatters: opts[:formatters] || @default_formatters,
      output_dir: Path.expand(opts[:output_dir] || @default_output_dir),
      try_compare?: opts[:try_compare?] || true
    }

    scenario
    |> Beamchmark.Suite.init(config)
    |> Beamchmark.Suite.run()
    |> tap(&Beamchmark.Suite.save/1)
    |> Beamchmark.Formatter.output()
  end
end
