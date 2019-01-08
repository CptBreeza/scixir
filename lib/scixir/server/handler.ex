defmodule Scixir.Server.Handler do
  @worker Scixir.Server.Supervisor.ensure_integer(Keyword.get(Application.get_env(:scixir, :redis), :worker), 5)

  def handle(data) do
    GenServer.cast(:"scixir_handler_worker_#{index()}", {:handle, data})
  end

  defp index do
    rem(System.unique_integer([:positive]), @worker)
  end
end
