defmodule Scixir.Engine do
  import Mogrify

  def process(%{intermediate_storage: intermediate_storage} = event, config) do
    out_files = do_process(intermediate_storage.in_file.file_path, config)
    %{event | intermediate_storage: Map.put(intermediate_storage, :out_files, out_files)}
  end

  defp do_process(file_path, %{versions: versions}) do
    Enum.map(versions, fn {version_name, size} ->
      outfile_path = Path.rootname(file_path) <> "_" <> to_string(version_name) <> Path.extname(file_path)
      open(file_path) |> resize_to_fill(size) |> gravity("Center") |> save(path: outfile_path)
      outfile_path
    end)
  end
end
