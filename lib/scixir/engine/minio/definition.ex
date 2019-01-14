defmodule Scixir.Engine.Minio.Definition do
  defmodule FileMetadata do
    defstruct [
      :bucket,
      :key,
      :url,
      :dirname,
      :basename,
    ]
  end

  alias Scixir.Utilities.Downloader

  def analyze_event(%{data: data}) do
    bucket = Kernel.get_in(data, [:s3, :bucket, :name])
    object_key = Kernel.get_in(data, [:s3, :object, :key])
    dirname = Path.dirname(object_key)
    basename = Path.basename(object_key)

    {:ok, url} =
      ExAws.S3.presigned_url(
        ExAws.Config.new(:s3, Application.get_all_env(:ex_aws)),
        :get,
        bucket,
        object_key
      )

    %FileMetadata{
      bucket: bucket,
      key: object_key,
      url: url,
      dirname: dirname,
      basename: basename
    }
  end

  def download(%FileMetadata{} = file_metadata) do
    {:ok, file_path} = Downloader.download(file_metadata)
    file_path
  end

  def upload(%FileMetadata{bucket: bucket, dirname: dirname}, file_path) do
    basename = Path.basename(file_path)

    key =
      if "." == dirname do
        basename
      else
        Path.join([dirname, Path.basename(file_path)])
      end

    file_path
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(bucket, key, meta: [scixir_generated: true])
    |> ExAws.request()
  end

  def clean_local_storage(%{intermediate_storage: intermediate_storage}) do
    files = [intermediate_storage.in_file.file_path | intermediate_storage.out_files]
    Enum.each(files, &File.rm(&1))
  end
end
