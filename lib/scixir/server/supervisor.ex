defmodule Scixir.Server.Supervisor do
  @moduledoc false

  use Supervisor
  require Logger

  @progress_scopes ~w{download_images resize_images upload_images}a
  @mix_env Mix.env()

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Logger.info fn -> "Initializing server" end

    %{host: host, notification_key: notification_key} = Map.new(Application.get_env(:scixir, :redis))

    children = [
      # Redis client
      {Redix, {host, [name: Scixir.Redis]}},

      # Event store
      {Scixir.Server.EventManager, :ok},

      # Event listener for Redis
      {Scixir.Server.EventListener, notification_key},

      {Scixir.Server.Main, {Scixir.Engine.Minio.Definition, Application.get_env(:scixir, :versions)}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
