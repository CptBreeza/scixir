defmodule Scixir.Engine do
  use Scixir.Engine.Middleware

  alias Scixir.Engine

  middleware Engine.Middlewares.Parser
  middleware Engine.Middlewares.Logger

  handle fn payload ->
    Engine.Adapters.Minio.handle(payload)
  end
end
