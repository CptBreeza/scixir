defmodule Scixir.Resizer do
  import Mogrify

  def resize(file_path, %{} = versions) when is_binary(file_path) do
    Enum.each(versions, fn {version_name, size} ->
      outfile_path = Path.rootname(file_path) <> "_" <> to_string(version_name) <> Path.extname(file_path)
      open(file_path) |> resize_to_fill(size) |> gravity("Center") |> save(path: outfile_path)
    end)
  end
end
