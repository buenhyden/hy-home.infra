# Django Project

## Overview
This directory contains the Docker Compose configuration for a Django development environment.

## Services
- **django**: The Django application container.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `DEFAULT_PYTHON_DJANGO_HOST_PORT`: Host port for the Django app.
- `DEFAULT_PYTHON_DJANGO_PORT`: Container port.
- `DEFAULT_SOURCECODE_DIR`: Base directory for source code.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **App**: `http://localhost:${DEFAULT_PYTHON_DJANGO_HOST_PORT}`

## Volumes
- `django-volume`: Mounts the source code from `${DEFAULT_SOURCECODE_DIR}/Django`.
