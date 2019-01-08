defmodule Scixir.Engine.Middlewares.Parser do
  @behaviour Scixir.Engine.Middleware

  @impl true
  def before_handle(%{data: [_notification_key, data]} = payload) do
    [_timestamp, [data]] = Jason.decode!(data, keys: :atoms)
    %{payload | data: data}
  end

  @impl true
  def after_handle(payload), do: payload
end
