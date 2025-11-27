# NestJS Project

## Overview
This directory contains the Docker Compose configuration for a NestJS development environment.

## Services
- **default-nestjs**: The NestJS application container.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `DEFAULT_NESTJS_HOST_PORT`: Host port for the NestJS app.
- `DEFAULT_NESTJS_PORT`: Container port.
- `DEFAULT_SOURCECODE_DIR`: Base directory for source code.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **App**: `http://localhost:${DEFAULT_NESTJS_HOST_PORT}`

## Volumes
- `default-nestjs-volume`: Mounts the source code from `${DEFAULT_SOURCECODE_DIR}/default-NestJS`.
