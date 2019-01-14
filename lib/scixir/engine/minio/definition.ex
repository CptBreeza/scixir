defmodule Scixir.Engine.Minio.Definition do
  def download(event) do
    IO.puts "Downloading..."
    event
  end

  def upload(event) do
    IO.puts "Uploading"
    event
  end
end
