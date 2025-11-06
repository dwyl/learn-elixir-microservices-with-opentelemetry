import Config

# NOTE: Runtime configuration (ports, URLs, credentials) is in config/runtime.exs
# This file only contains compile-time configuration

# Configure Ecto repos (database path is in runtime.exs)
config :image_svc,
  ecto_repos: [ImageService.Repo],
  adapter: Ecto.Adapters.SQLite3,
  default_transaction_mode: :immediate,
  show_sensitive_data_on_connection_error: true,
  pool_size: 5

# PromEx configuration for Prometheus metrics
config :image_svc, ImageSvc.PromEx,
  disabled: false,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: :disabled,
  metrics_server: :disabled

# Add service name to all logs
config :logger, :default_formatter, metadata: [:service]

# OpenTelemetry Configuration
config :opentelemetry,
  service_name: "image_svc",
  traces_exporter: :otlp
