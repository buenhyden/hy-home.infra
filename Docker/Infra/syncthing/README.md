# Syncthing

## Overview
This directory contains the Docker Compose configuration for running Syncthing, a continuous file synchronization program.

## Services
- **syncthing**: The Syncthing server.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `SYNCTHING_SYNC_HOST_PORT`: Port for sync traffic.
- `SYNCTHING_GUI_PORT`: Port for the Web GUI.
- `SYNCTHING_USERNAME`, `SYNCTHING_PASSWORD`: Web GUI credentials.
- `PUID`, `PGID`: User/Group IDs for file permissions.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **Web GUI**: `http://localhost:${SYNCTHING_GUI_PORT}`

## Volumes
- `syncthing-volume`: Stores configuration and metadata.
- `resources-contents-volume`: The actual directory being synced.
