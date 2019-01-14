defmodule Scixir.Redis do
  def persist_failure(event) do
    IO.puts "Persisting"
    event
  end
end
