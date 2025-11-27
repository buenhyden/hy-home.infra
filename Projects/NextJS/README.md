# NextJS Project

## Overview
This directory contains the Docker Compose configuration for a NextJS development environment.

## Services
- **default-nextjs**: The NextJS application container.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `DEFAULT_NEXTJS_HOST_PORT`: Host port for the NextJS app.
- `DEFAULT_NEXTJS_PORT`: Container port.
- `DEFAULT_SOURCECODE_DIR`: Base directory for source code.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **App**: `http://localhost:${DEFAULT_NEXTJS_HOST_PORT}`

## Volumes
- `default-nextjs-volume`: Mounts the source code from `${DEFAULT_SOURCECODE_DIR}/default-NextJS`.
