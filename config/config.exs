import Config

if "#{config_env()}.exs" |> Path.expand(__DIR__) |> File.exists?() do
  import_config "#{config_env()}.exs"
end

if "#{config_env()}.secret.exs" |> Path.expand(__DIR__) |> File.exists?() do
  import_config "#{config_env()}.secret.exs"
end
