defmodule Scixir.Server.Supervisor do
  use Supervisor
  require Logger

  @default_worker 5

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Logger.info("Initializing server")

    %{url: url, notification_key: notification_key, worker: worker} = Map.new(Application.get_env(:scixir, :redis))
    worker = ensure_integer(worker, @default_worker)

    children = [
      {Redix, {url, [name: Scixir.Redis]}},
      {Scixir.Server.EventListener, {{notification_key, 5}, [name: Scixir.Server.EventListener]}},
      {Scixir.Server.Handler.Supervisor, {worker, [name: Scixir.Server.Handler.Supervisor]}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def ensure_integer(data, _default) when is_binary(data), do: String.to_integer(data)
  def ensure_integer(data, _default) when is_integer(data), do: data
  def ensure_integer(_data, default), do: default
end
