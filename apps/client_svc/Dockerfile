FROM elixir:1.19.1-erlang-28.1-alpine-3.22.2 as builder
RUN mix local.hex --force && mix local.rebar --force
WORKDIR /app
COPY . /app
RUN mix deps.get
RUN MIX_ENV=prod mix release

FROM alpine:latest as app
RUN apk add bash openssl
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/opentelemetry_demo .
CMD bin/opentelemetry_demo start