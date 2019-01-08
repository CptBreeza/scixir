defmodule Scixir.Engine.Middleware do
  @callback before_handle(%Scixir.Engine.Payload{}) :: %Scixir.Engine.Payload{}
  @callback after_handle(%Scixir.Engine.Payload{}) :: %Scixir.Engine.Payload{}

  defmacro __using__(_) do
    quote location: :keep, generated: true do
      import unquote(__MODULE__), only: [middleware: 1, handle: 1]
      @before_compile unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :middlewares, accumulate: true)
    end
  end

  defmacro __before_compile__(_) do
    quote location: :keep, generated: true do
      def handle(payload) do
        payload =
          @middlewares
          |> Enum.reverse()
          |> Enum.reduce(payload, fn middleware, result ->
            middleware.before_handle(result)
          end)

        __do_handle__(payload)

        Enum.reduce(@middlewares, payload, fn middleware, result ->
          middleware.after_handle(result)
        end)
      end
    end
  end

  defmacro middleware(middleware) do
    quote location: :keep, generated: true do
      @middlewares unquote(middleware)
    end
  end

  defmacro handle(function) do
    quote location: :keep, generated: true do
      def __do_handle__(payload) do
        unquote(function).(payload)
      end
    end
  end
end
