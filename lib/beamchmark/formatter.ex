defmodule Beamchmark.Formatter do
  @moduledoc false

  alias Beamchmark.{Suite, Configuration}

  @type t :: module()

  @typedoc """
  Options given to formatters.
  """
  @type options :: map()

  @doc """
  Takes the suite and returns whatever representation the formatter wants to use
  to output that information. It is important that this function **needs to be
  pure** (aka have no side effects) as Benchee will run `format/1` functions
  of multiple formatters in parallel. The result will then be passed to
  `write/1`.
  """
  @callback format(Suite.t(), options) :: any

  @callback format(Suite.t(), Suite.t(), options) :: any

  @doc """
  Takes the return value of `format/1` and then performs some I/O for the user
  to actually see the formatted data (UI, File IO, HTTP, ...)
  """
  @callback write(any, options) :: :ok | {:error, String.t()}

  @spec output(Suite.t()) :: :ok | {:error, String.t()}
  def output(%Suite{} = suite) do
    with true <- suite.configuration.try_compare?,
         {:ok, base_suite} <- Suite.try_load_base(suite) do
      output_diff(suite, base_suite)
    else
      false ->
        output_single(suite)

      {:error, posix} ->
        Mix.shell().info("""
        Comparison is enabled, but did not found any previous measurements (error: #{inspect(posix)}).
        Proceeding with single suite...
        """)

        output_single(suite)
    end
  end

  defp output_single(%Suite{} = suite) do
    suite
    |> get_formatters()
    |> Enum.each(fn {formatter, options} ->
      :ok =
        suite
        |> formatter.format(options)
        |> formatter.write(options)
    end)
  end

  defp output_diff(%Suite{} = suite, %Suite{} = base) do
    suite
    |> get_formatters()
    |> Enum.each(fn {formatter, options} ->
      :ok =
        suite
        |> formatter.format(base, options)
        |> formatter.write(options)
    end)
  end

  defp get_formatters(%Suite{configuration: %Configuration{} = config}) do
    config.formatters
    |> Enum.map(fn formatter ->
      case formatter do
        {module, options} -> {module, options}
        module -> {module, %{}}
      end
    end)
    |> tap(fn formatters -> Enum.each(formatters, &validate/1) end)
  end

  defp validate({formatter, options}) when not is_map(options),
    do:
      raise(
        "Options for #{inspect(formatter)} need to be passed as a map. Got: #{inspect(options)}."
      )

  defp validate({formatter, _options}) do
    implements_formatter? =
      formatter.module_info(:attributes)
      |> Keyword.get(:behaviour, [])
      |> Enum.member?(__MODULE__)

    unless implements_formatter? do
      raise "#{inspect(formatter)} does not implement #{inspect(__MODULE__)} behaviour."
    end
  end
end
