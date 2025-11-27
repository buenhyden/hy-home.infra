# ReactJS Project

## Overview
This directory contains the Docker Compose configuration for a ReactJS development environment (typically using Vite).

## Services
- **default-reactjs**: The ReactJS application container.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `DEFAULT_REACTJS_HOST_PORT`: Host port for the React app.
- `DEFAULT_VITE_HOST_PORT`: Host port for Vite HMR/dev server.
- `DEFAULT_REACTJS_PORT`, `DEFAULT_VITE_PORT`: Container ports.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **App**: `http://localhost:${DEFAULT_REACTJS_HOST_PORT}`

## Volumes
- `reactjs-volume`: Mounts the source code.
