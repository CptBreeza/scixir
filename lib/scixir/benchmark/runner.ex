defmodule Scixir.Benchmark.Runner do
  @test_images_dir "/home/breeza/test_pics"
  @bucket "btest"

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def run do
    GenServer.call(__MODULE__, :run, :infinity)
  end

  @impl true
  def init(:ok) do
    {:ok, nil}
  end

  @impl true
  def handle_call(:run, _from, _state) do
    run(@test_images_dir)

    {:noreply, nil}
  end

  defp run(test_images_dir) do
    Enum.each(0..4, &do_run(test_images_dir, &1))
  end

  @ranges [
    [1, 400],
    [401, 800],
    [801, 1200],
    [1201, 1600],
    [1601, 2000]
  ]

  defp do_run(test_images_dir, iteration) do
    Enum.each(@ranges, fn [lower, upper] ->
      lower..upper
      |> Enum.map(fn index ->
        Task.async(fn -> upload_image(test_images_dir, iteration * 2000 + index) end)
      end)
      |> Enum.each(&Task.await/1)
    end)
  end

  defp upload_image(test_images_dir, index) do
    key = "img_#{index}.jpg"
    path = Path.join(test_images_dir, key)

    path
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(@bucket, key)
    |> ExAws.request()
  end
end
