defmodule Scixir.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Scixir.Server.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Scixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
