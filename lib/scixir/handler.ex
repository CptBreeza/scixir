defmodule Scixir.Handler do
  def handle(data) do
    IO.inspect(self())
    IO.inspect(data)
  end
end
