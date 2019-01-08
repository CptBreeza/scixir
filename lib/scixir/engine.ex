defmodule Scixir.Engine do
  def handle(data) do
    IO.inspect(self())
    IO.inspect(data)
  end
end
