# MinIO

## Overview
This directory contains the Docker Compose configuration for running MinIO, a high-performance, S3 compatible object storage.

## Services
- **minio**: The MinIO server.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `MINIO_HOST_PORT`: Host port for the S3 API.
- `MINIO_CONSOLE_HOST_PORT`: Host port for the MinIO Console.
- `MINIO_PORT`, `MINIO_CONSOLE_PORT`: Container ports.

It also uses Docker secrets for sensitive data:
- `minio_root_user`
- `minio_root_password`

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **MinIO Console**: `http://localhost:${MINIO_CONSOLE_HOST_PORT}`
- **S3 API**: `http://localhost:${MINIO_HOST_PORT}`

## Volumes
- `minio-data`: Persistent storage for objects.
