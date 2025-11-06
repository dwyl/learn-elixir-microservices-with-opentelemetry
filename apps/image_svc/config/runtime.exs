import Config

# Runtime configuration for image_svc

# HTTP Port
port = System.get_env("IMAGE_SVC_PORT", "8084") |> String.to_integer()

config :image_svc,
  port: port,
  user_svc_base_url:
    System.get_env("USER_SVC_URL", "http://127.0.0.1:#{System.get_env("USER_SVC_PORT", "8081")}"),
  user_svc_endpoints: %{
    store_image: "/user_svc/store_image/v1",
    notify_user: "/user_svc/notify_user/v1",
    image_loader: "/user_svc/image_loader/v1"
  }

# Database configuration (SQLite)------------------------
# In Docker: /app/db/service.db
# In dev: db/service.db

config :image_svc, ImageService.Repo,
  database: System.get_env("DATABASE_PATH", "db/service.db"),
  pool_size: String.to_integer(System.get_env("DB_POOL_SIZE", "5")),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

# Determine OTLP protocol from environment variable------------------------
# Options: "http" (default) or "grpc" (production)
otlp_protocol =
  case System.get_env("OTEL_EXPORTER_OTLP_PROTOCOL", "http") do
    "grpc" ->
      :grpc

    "http" ->
      :http_protobuf

    other ->
      IO.warn("Unknown OTLP protocol '#{other}', defaulting to :http_protobuf")
      :http_protobuf
  end

otlp_endpoint =
  case System.get_env("OTEL_EXPORTER_OTLP_ENDPOINT") do
    nil -> "http://127.0.0.1:4318"
    endpoint -> endpoint
  end

config :opentelemetry_exporter,
  otlp_protocol: otlp_protocol,
  otlp_endpoint: otlp_endpoint

# Logger configuration - uses Docker Loki driver for log shipping------------------------
config :logger,
  level: System.get_env("LOG_LEVEL", "info") |> String.to_atom()

# Optionally configure JSON logging
if System.get_env("LOG_FORMAT") == "json" do
  config :logger, :default_handler,
    formatter:
      {LoggerJSON.Formatters.Basic,
       metadata: [
         :request_id,
         :service,
         :trace_id,
         :span_id,
         :user_id,
         :duration
       ]}
end
