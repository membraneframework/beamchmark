defmodule Beamchmark.Suite do
  @moduledoc """
  The module defines a struct representing a single run of benchmark. It is also responsible for running the
  benchmark and saving/loading the results.

  The results are serialized and stored in `output_dir / scenario name / delay_duration` directory, where
  `scenario name` is the name of module implementing scenario (without separating dots) and `output_dir`,
  `delay`, `duration` are fetched from the suite's configuration.
  """

  alias Beamchmark.Scenario

  alias __MODULE__.{Configuration, SystemInfo, Measurements}

  @type t :: %__MODULE__{
          scenario: Scenario.t(),
          configuration: Configuration.t(),
          system_info: SystemInfo.t(),
          measurements: Measurements.t() | nil
        }

  @enforce_keys [
    :scenario,
    :configuration,
    :system_info,
    :measurements
  ]
  defstruct @enforce_keys

  @suite_filename "suite"
  @old_suite_filename "suite_old"

  @spec init(Scenario.t(), Configuration.t()) :: t()
  def init(scenario, %Configuration{} = configuration) do
    implements_scenario? =
      scenario.module_info(:attributes)
      |> Keyword.get(:behaviour, [])
      |> Enum.member?(Scenario)

    unless implements_scenario? do
      raise "#{inspect(scenario)} is not a module implementing #{inspect(Scenario)} behaviour."
    end

    %__MODULE__{
      scenario: scenario,
      configuration: configuration,
      system_info: SystemInfo.init(),
      measurements: nil
    }
  end

  @spec run(t()) :: t()
  def run(%__MODULE__{scenario: scenario, configuration: config} = suite) do
    Mix.shell().info("Running scenario \"#{inspect(scenario)}\"...")
    task = Task.async(fn -> suite.scenario.run() end)

    Mix.shell().info("Waiting #{inspect(config.delay)} seconds...")
    Process.sleep(:timer.seconds(config.delay))

    Mix.shell().info("Benchmarking for #{inspect(config.duration)} seconds...")
    measurements = Measurements.gather(config.duration)

    case Task.shutdown(task, :brutal_kill) do
      # the scenario was still running
      nil ->
        %__MODULE__{suite | measurements: measurements}

      # the scenario has finished before (config.delay + config.duration) seconds
      {:ok, _result} ->
        Mix.shell().error("""
        The scenario had been completed before the measurements ended.
        Consider decreasing duration/delay or making the scenario run longer to get more accurate results.
        """)

        %__MODULE__{suite | measurements: measurements}

      # should never happen
      {:exit, reason} ->
        raise "The scenario process unexpectedly died due to #{inspect(reason)}."
    end
  end

  @spec save(t()) :: :ok
  def save(%__MODULE__{configuration: config} = suite) do
    output_dir = output_dir_for(suite)
    File.mkdir_p!(output_dir)

    new_path = Path.join([output_dir, @suite_filename])
    old_path = Path.join([output_dir, @old_suite_filename])

    if File.exists?(new_path) do
      File.rename!(new_path, old_path)
    end

    File.write!(new_path, :erlang.term_to_binary(suite))

    Mix.shell().info("The results were saved to \"#{inspect(config.output_dir)}`\" directory.")
  end

  @spec try_load_base(t()) :: {:ok, t()} | {:error, File.posix()}
  def try_load_base(%__MODULE__{} = suite) do
    output_dir = output_dir_for(suite)

    with old_path <- Path.join([output_dir, @old_suite_filename]),
         {:ok, suite} <- File.read(old_path),
         suite <- :erlang.binary_to_term(suite) do
      {:ok, suite}
    end
  end

  defp output_dir_for(%__MODULE__{configuration: config} = suite) do
    scenario_dir = suite.scenario |> Atom.to_string() |> String.replace(".", "")
    config_dir = "#{config.delay}_#{config.duration}"

    Path.join([config.output_dir, scenario_dir, config_dir])
  end
end
