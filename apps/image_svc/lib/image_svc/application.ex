defmodule ImageSvc.Application do
  @moduledoc """
  Image Service Application

  Responsible for image processing operations (PNG to PDF conversion, etc.)
  Receives requests via HTTP and processes them using ImageMagick.
  """

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    :ok =
      case ImageConverter.check_imagemagick() do
        {:ok, _} ->
          :ok

        {:error, reason} ->
          Logger.error("ImageMagick check failed: #{reason}")
          raise "Imagemagick is not installed"
      end

    # ImageService.Release.migrate()
    # OpentelemetryEcto.setup([:image_svc, :ecto_repos])

    port = Application.get_env(:image_svc, :port, 8084)
    Logger.info("Starting IMAGE SERVICE on port #{port}")

    children = [
      # PromEx must start before Repo to capture Ecto init events
      ImageSvc.PromEx,
      # ImageService.Repo,
      ImageSvc.Metrics,
      {Bandit, plug: ImageSvc.Router, port: port}
    ]

    opts = [strategy: :one_for_one, name: ImageSvc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
