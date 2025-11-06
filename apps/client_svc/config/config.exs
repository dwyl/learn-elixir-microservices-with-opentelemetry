import Config

# This file only contains compile-time configuration

# PromEx configuration for Prometheus metrics
config :client_svc, ClientSvc.PromEx,
  disabled: false,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: :disabled,
  metrics_server: :disabled

# Logger configuration - uses Docker Loki driver for log shipping
config :logger,
  level: :info

# Add service name to all logs
config :logger, :default_formatter, metadata: [:service]

# OpenTelemetry Configuration
config :opentelemetry, :resource, %{service: "client_svc"}

config :opentelemetry, traces_exporter: :otlp

config :opentelemetry,
       :processors,
       otel_batch_processor: %{
         exporter: {:otel_exporter_otlp, []}
       }
