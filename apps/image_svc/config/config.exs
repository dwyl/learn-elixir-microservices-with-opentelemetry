import Config

# NOTE: Runtime configuration (ports, URLs, credentials) is in config/runtime.exs
# This file only contains compile-time configuration

config :exqlite,
  force_build: true,
  default_chunk_size: 100

config :image_svc,
  ecto_repos: [ImageService.Repo],
  adapter: Ecto.Adapters.SQLite3,
  default_transaction_mode: :immediate,
  show_sensitive_data_on_connection_error: true,
  stacktrace: true,
  pool_size: 5

# PromEx configuration for Prometheus metrics--------------------------
config :image_svc, ImageService.PromEx,
  disabled: false,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: :disabled,
  metrics_server: :disabled

config :image_svc,
  conversion_cache_db: "db/conversion_cache.sql3",
  default_converter: ImageSvc.ParallelConverter,
  # StreamingConverter
  default_threads: System.schedulers_online() |> div(2),
  enable_streaming: true

# OpenTelemetry -------------------------------------------------------
config :opentelemetry,
  span_processor: :batch,
  traces_exporter: :otlp,
  resource: %{service: "image_svc"}

config :opentelemetry_ecto, :tracer, repos: [ImageService.Repo]

# Add service name to all logs
config :logger, :default_formatter, metadata: [:service]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
