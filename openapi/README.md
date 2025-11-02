# OpenAPI Documentation

This directory contains OpenAPI 3.0 specifications for all microservices.

## Specifications

- **[user_svc.yaml](user_svc.yaml)** - User Service API (port 8081)
- **[job_svc.yaml](job_svc.yaml)** - Job Service API (port 8082)
- **[image_svc.yaml](image_svc.yaml)** - Image Service API (port 8084)

## Viewing the Documentation

### Option 1: Swagger UI (Docker)

```bash
# Serve all specs with Swagger UI
docker run -p 8080:8080 \
  -e URLS="[ \
    {url: 'user_svc.yaml', name: 'User Service'}, \
    {url: 'job_svc.yaml', name: 'Job Service'}, \
    {url: 'image_svc.yaml', name: 'Image Service'} \
  ]" \
  -v $(pwd):/usr/share/nginx/html/api \
  swaggerapi/swagger-ui

# Then open http://localhost:8080
```

### Option 2: Swagger Editor (Online)

1. Go to https://editor.swagger.io/
2. Copy/paste the YAML content
3. View interactive documentation

### Option 3: Redoc (Prettier Docs)

```bash
# Install globally
npm install -g redoc-cli

# Generate static HTML
redoc-cli bundle user_svc.yaml -o user_svc.html
redoc-cli bundle job_svc.yaml -o job_svc.html
redoc-cli bundle image_svc.yaml -o image_svc.html

# Open in browser
open user_svc.html
```

### Option 4: VSCode Extension

Install the **OpenAPI (Swagger) Editor** extension:
- Extension ID: `42Crunch.vscode-openapi`
- Provides syntax highlighting and preview

## Updating Documentation

When you add/modify endpoints:

1. Update the corresponding YAML file
2. Validate with: `npx @apidevtools/swagger-cli validate <file>.yaml`
3. Commit changes to git

## Notes

- All services use **Protobuf binary serialization** (`application/x-protobuf`)
- The OpenAPI specs document the HTTP interface, not the Protobuf schemas
- For detailed Protobuf message definitions, see [../protos/image.proto](../protos/image.proto)
- Streaming endpoints (`/user/stream`, `/events`, `/stream/:count`) are demo endpoints

## Architecture

```
Client (port 4000)
    ↓
User Service (port 8081) ← Main orchestrator
    ↓
Job Service (port 8082) ← Async job queue (Oban)
    ↓
Image Service (port 8084) ← Image processing (ImageMagick)
    ↓
MinIO (port 9000) ← Object storage
```

## Service Communication Flow

### Image Conversion Flow:
```
1. Client → user_svc/ConvertImage (stores PNG in MinIO)
2. user_svc → job_svc/ConvertImage (enqueues Oban job)
3. job_svc → image_svc/ConvertImage (processes conversion)
4. image_svc → user_svc/StoreImage (stores PDF, notifies client)
5. Client receives presigned URL for PDF download
```

See [../ARCHITECTURE.md](../ARCHITECTURE.md) for more details.
