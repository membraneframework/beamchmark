defmodule Beamchmark.Formatter do
  @moduledoc """
  The module defines a  behaviour that will be used to format and output `#{inspect(Beamchmark.Suite)}`.
  You can adopt this behaviour to implement custom formatters.

  The module contains helper functions for validating and applying formatters defined in configuration
  of `#{inspect(Beamchmark.Suite)}`.
  """

  alias Beamchmark.Suite

  @typedoc """
  Represents a module implementing `#{inspect(__MODULE__)}` behaviour.
  """
  @type t :: module()

  @typedoc """
  Options given to formatters (defined by formatters authors).
  """
  @type options_t :: Keyword.t()

  @doc """
  Takes the suite and transforms it into some internal representation, that later on will be passed to
  `write/2`.
  """
  @callback format(Suite.t(), options_t) :: any()

  @doc """
  Works like `format/2`, but can provide additional information by comparing the latest suite with the
  previous one (passed as the second argument).
  """
  @callback format(Suite.t(), Suite.t(), options_t) :: any()

  @doc """
  Takes the return value of `format/1` or `format/2` and outputs it in a convenient form (stdout, file, UI...).
  """
  @callback write(any, options_t) :: :ok

  @doc """
  Takes the suite and uses its formatters to output it. If the suite was configured with `compare?` flag enabled,
  the previous suite will be also provided to the formatters.
  """
  @spec output(Suite.t()) :: :ok
  def output(%Suite{} = suite) do
    with true <- suite.configuration.compare?,
         {:ok, base_suite} <- Suite.try_load_base(suite) do
      output_compare(suite, base_suite)
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

  defp output_compare(%Suite{} = suite, %Suite{} = base) do
    suite
    |> get_formatters()
    |> Enum.each(fn {formatter, options} ->
      :ok =
        suite
        |> formatter.format(base, options)
        |> formatter.write(options)
    end)
  end

  defp get_formatters(%Suite{configuration: config}) do
    config.formatters
    |> Enum.map(fn formatter ->
      case formatter do
        {module, options} -> {module, options}
        module -> {module, []}
      end
    end)
    |> tap(fn formatters -> Enum.each(formatters, &validate/1) end)
  end

  defp validate({formatter, options}) do
    unless Keyword.keyword?(options) do
      raise(
        "Options for #{inspect(formatter)} need to be passed as a keyword list. Got: #{inspect(options)}."
      )
    end

    implements_formatter? =
      formatter.module_info(:attributes)
      |> Keyword.get(:behaviour, [])
      |> Enum.member?(__MODULE__)

    unless implements_formatter? do
      raise "#{inspect(formatter)} does not implement #{inspect(__MODULE__)} behaviour."
    end
  end
end
