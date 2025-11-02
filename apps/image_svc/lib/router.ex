defmodule ImageSvc.Router do
  use Plug.Router
  require Logger

  plug(:match)
  plug(Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason,
    pass: ["application/protobuf"]
  )

  # OpenAPI spec generation
  plug(OpenApiSpex.Plug.PutApiSpec, module: ImageSvc.ApiSpec)

  plug(:dispatch)

  # OpenAPI documentation endpoints
  get "/api/openapi" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(ImageSvc.ApiSpec.spec()))
  end

  # Swagger UI
  get "/swaggerui" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, """
    <!DOCTYPE html>
    <html>
    <head>
      <title>Image Service API</title>
      <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
    </head>
    <body>
      <div id="swagger-ui"></div>
      <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
      <script>
        SwaggerUIBundle({
          url: '/api/openapi',
          dom_id: '#swagger-ui',
          deepLinking: true,
          presets: [
            SwaggerUIBundle.presets.apis,
            SwaggerUIBundle.SwaggerUIStandalonePreset
          ]
        })
      </script>
    </body>
    </html>
    """)
  end

  # RPC-style protobuf endpoint
  # ImageService.ConvertImage - Convert image to PDF
  post "/image_svc/ConvertImage" do
    ImageSvc.ConversionController.convert(conn)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
