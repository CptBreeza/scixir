defmodule Scixir.Benchmark.ProgressDecorator do
  @moduledoc false

  use Decorator.Define, [progress: 0]

  def progress(body, context) do
    quote do
      reply = unquote(body)

      case reply do
        list when is_list(list) -> Scixir.Benchmark.Progress.incr(unquote(context.name), length(list))
        _ -> Scixir.Benchmark.Progress.incr(unquote(context.name))
      end

      reply
    end
  end
end
