# Scixir

## 流程

1. 从外部源（Minio 会把事件推到 Redis 里）接收事件
2. 解析事件，向流水线派发事件
3. Stage 1: 从 OSS 下载图片
4. Stage 2: 在本地裁剪图片
5. Stage 3: 向 OSS 上传图片

其中 Stage 1/2/3 均有多个 workers（进程）

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `scixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:scixir, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/scixir](https://hexdocs.pm/scixir).

