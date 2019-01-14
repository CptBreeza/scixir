defmodule Scixir.Utilities.Downloader do
  @local_storage Path.join(:code.priv_dir(:scixir), "local-storage")

  alias Scixir.Engine.Minio.Definition.FileMetadata

  def download(%FileMetadata{url: url, dirname: dirname, key: key}) do
    dir = Path.join(@local_storage, dirname)
    unless File.dir?(dir) do
      File.mkdir_p!(dir)
    end

    @local_storage
    |> Path.join(key)
    |> do_download(url)
  end

  defp do_download(path, url) do
    File.touch!(path)
    file = File.open!(path, [:write])

    %HTTPoison.AsyncResponse{id: ref} = HTTPoison.get!(url, [], stream_to: self())

    case receive_loop(ref, file, nil) do
      %HTTPoison.AsyncStatus{code: 200} -> {:ok, path}
      %HTTPoison.AsyncStatus{code: code} ->
        File.rm(path)
        {:error, :download_error, {:code, code}}
    end
  end

  defp receive_loop(ref, file, status) do
    receive do
      %HTTPoison.AsyncStatus{} = status ->
        receive_loop(ref, file, status)
      %HTTPoison.AsyncChunk{chunk: chunk, id: ^ref} ->
        IO.binwrite(file, chunk)
        receive_loop(ref, file, status)
      %HTTPoison.AsyncEnd{id: ^ref} ->
        File.close(file)
        status
      _ ->
        receive_loop(ref, file, status)
    end
  end
end
