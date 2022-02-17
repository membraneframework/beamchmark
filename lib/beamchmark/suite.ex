defmodule Beamchmark.Suite do
  @moduledoc false

  alias Beamchmark.{SystemInfo, Scenario, Measurements, Configuration}

  @type t :: %__MODULE__{
          system_info: SystemInfo.t(),
          scenario: Scenario.t(),
          measurements: Measurements.t(),
          configuration: Configuration.t()
        }

  @enforce_keys [
    :system_info,
    :scenario,
    :measurements,
    :configuration
  ]
  defstruct @enforce_keys

  @spec init(Scenario.t(), Configuration.t()) :: t()
  def init(scenario, %Configuration{} = configuration) do
    implements_scenario? =
      scenario.module_info(:attributes)
      |> Keyword.get(:behaviour, [])
      |> Enum.member?(Scenario)

    unless implements_scenario? do
      raise "#{inspect(scenario)} is not a module implementing #{inspect(Scenario)} behaviour"
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

    Mix.shell().info("Benchmarking for #{inspect(config.duration)} seconds...\n")
    measurements = Measurements.gather(config.duration)

    :ok = Task.await(task, :infinity)

    %__MODULE__{suite | measurements: measurements}
  end

  @spec save(t()) :: :ok
  def save(%__MODULE__{configuration: config} = suite) do
    output_file = Path.join([config.output_dir, "beamchmark_suite"])

    if File.exists?(output_file) do
      :ok = File.rename!(output_file, Path.join([config.output_dir, "beamchmark_suite_old"]))
    end

    File.mkdir_p(config.output_dir)

    File.write!(output_file, :erlang.term_to_binary(suite))
  end

  @spec try_load_base(t()) :: {:ok, t()} | {:error, File.posix()}
  def try_load_base(%__MODULE__{configuration: config}) do
    with old_path <- Path.join([config.output_dir, "beamchmark_suite_old"]),
         {:ok, suite} <- File.read(old_path),
         suite <- :erlang.binary_to_term(suite) do
      {:ok, suite}
    end
  end
end
