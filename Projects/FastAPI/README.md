# FastAPI Project

## Overview
This directory contains the Docker Compose configuration for a FastAPI development environment.

## Services
- **fastapi**: The FastAPI application container.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `DEFAULT_PYTHON_FASTAPI_HOST_PORT`: Host port for the FastAPI app.
- `DEFAULT_PYTHON_FASTAPI_PORT`: Container port.
- `DEFAULT_SOURCECODE_DIR`: Base directory for source code.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **App**: `http://localhost:${DEFAULT_PYTHON_FASTAPI_HOST_PORT}`
- **Docs**: `http://localhost:${DEFAULT_PYTHON_FASTAPI_HOST_PORT}/docs` (Default FastAPI docs path)

## Volumes
- `fastapi-volume`: Mounts the source code from `${DEFAULT_SOURCECODE_DIR}/FastAPI`.
