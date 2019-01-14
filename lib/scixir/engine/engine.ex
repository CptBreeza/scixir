defmodule Scixir.Engine do
  import Mogrify

  def process(%{intermediate_storage: intermediate_storage} = event, %{versions: versions}) do
    %{in_file: file} = intermediate_storage

    out_files =
      Enum.map(versions, fn {version_name, size} ->
        outfile_path = Path.rootname(file.path) <> "_" <> to_string(version_name) <> Path.extname(file.path)
        open(file.path) |> resize_to_fill(size) |> gravity("Center") |> save(path: outfile_path)
        %Arc.File{path: outfile_path}
      end)

    %{event | intermediate_storage: Map.put(intermediate_storage, :out_files, out_files)}
  end
end
