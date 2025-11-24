# Keycloak

## Overview
This directory contains the Docker Compose configuration for running Keycloak in development mode.

## Services
- **keycloak**: Identity and Access Management server.

## Prerequisites
- Docker and Docker Compose installed.

## Configuration
The service is configured for development use:
- `KC_HOSTNAME`: localhost
- `KC_HTTP_PORT`: 8080

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **Keycloak Admin Console**: `http://localhost:18080`

## Notes
- This configuration uses `start-dev` and is not suitable for production.
- For production, configure an external database (PostgreSQL) and proper SSL/TLS.
