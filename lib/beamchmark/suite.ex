defmodule Beamchmark.Suite do
  @moduledoc """
  The module defines a struct representing a single run of benchmark.
  It is responsible for benchmarking and saving/loading the results.
  """

  alias Beamchmark.Scenario
  alias Beamchmark.Suite.CPU.CPUTask

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
  def init(scenario, configuration) do
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
    # TODO: what about scenarios that take less than `delay + duration` seconds or run indefinitely?
    Mix.shell().info("Running scenario \"#{inspect(scenario)}\"...")
    task = Task.async(fn -> suite.scenario.run() end)

    Mix.shell().info("Waiting #{inspect(config.delay)} seconds...")
    Process.sleep(:timer.seconds(config.delay))

    Mix.shell().info("Benchmarking for #{inspect(config.duration)} seconds...")
    measurements = Measurements.gather(config.duration)

    # TODO There cpu_task is handled

    cpu_task = CPUTask.start_link()

    _result = Task.await(cpu_task, :infinity)

    case Task.await(task, :infinity) do
      :ok ->
        %__MODULE__{suite | measurements: measurements}

      {:error, reason} ->
        raise "The scenario failed due to #{inspect(reason)}."

      value ->
        raise "Invalid return value from scenario: #{inspect(value)}. Expected output is ether `:ok` or `{:error, reason}`."
    end
  end

  @spec save(t()) :: :ok
  def save(%__MODULE__{configuration: config} = suite) do
    File.mkdir_p!(config.output_dir)

    new_path = Path.join([config.output_dir, @suite_filename])
    old_path = Path.join([config.output_dir, @old_suite_filename])

    if File.exists?(new_path) do
      File.rename!(new_path, old_path)
    end

    File.write!(new_path, :erlang.term_to_binary(suite))

    Mix.shell().info("Results successfully saved to #{inspect(config.output_dir)} directory.")
  end

  @spec try_load_base(t()) :: {:ok, t()} | {:error, File.posix()}
  def try_load_base(%__MODULE__{configuration: config}) do
    with old_path <- Path.join([config.output_dir, @old_suite_filename]),
         {:ok, suite} <- File.read(old_path),
         suite <- :erlang.binary_to_term(suite) do
      {:ok, suite}
    end
  end
end
