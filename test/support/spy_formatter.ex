defmodule SpyFormatter do
  @moduledoc false

  @behaviour Beamchmark.Formatter

  @impl true
  def format(suite, options) do
    send(options[:pid], {suite, options})
    :ok
  end

  @impl true
  def format(new_suite, base_suite, options) do
    send(options[:pid], {new_suite, base_suite, options})
    :ok
  end

  @impl true
  def write(data, options) do
    send(options[:pid], {data, options})
    :ok
  end
end
