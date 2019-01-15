defmodule Scixir.Benchmark.Progress do
  @moduledoc false

  use GenServer

  @timers :millisecond
  @logfiles_dir Path.join([:code.priv_dir(:scixir), "logs"])

  def start_link(scopes \\ []) do
    GenServer.start_link(__MODULE__, scopes, name: __MODULE__)
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  def incr(scope, n \\ 1) do
    GenServer.cast(__MODULE__, {:incr, scope, n})
  end


  @impl true
  def init(scopes) do
    files =
      Enum.map(scopes, fn scope ->
        {
          scope,
          @logfiles_dir |> Path.join("progress-#{scope}.log") |> File.open!([:write])
        }
      end)

    counts = Enum.map(scopes, fn scope -> {scope, 0} end)
    time = :os.system_time(@timers)
    Enum.each(files, fn {_, io} -> write(io, time, 0) end)

    {:ok, {time, files, counts}}
  end

  @impl true
  def handle_cast({:incr, scope, n}, {time, files, counts}) do
    {value, counts} = Keyword.get_and_update!(counts, scope, &({&1 + n, &1 + n}))
    write(files[scope], time, value)

    {:noreply, {time, files, counts}}
  end

  defp write(file, time, value) do
    time = :os.system_time(@timers) - time
    IO.write(file, "#{time}\t#{value}\n")
  end
end
