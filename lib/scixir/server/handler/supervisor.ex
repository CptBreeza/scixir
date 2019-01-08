defmodule Scixir.Server.Handler.Supervisor do
  use Supervisor
  require Logger

  def start_link({arg, options}) do
    Supervisor.start_link(__MODULE__, arg, options)
  end

  @impl true
  def init(worker) do
    Logger.info("Initializing workers")

    children =
      for i <- 1..worker do
        Supervisor.child_spec({Scixir.Server.Handler.Worker, [name: :"scixir_handler_worker_#{i}"]}, id: {Scixir.Server.Handler.Worker, i})
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
