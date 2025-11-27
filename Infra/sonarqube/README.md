# SonarQube

## Overview
This directory contains the Docker Compose configuration for running SonarQube Community Edition. It is configured to use an external PostgreSQL database.

## Services
- **sonarqube**: The SonarQube server.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.
- External PostgreSQL service running.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `SONARQUBE_PORT`: Container port.
- `SONAR_JDBC_URL`: Database connection string.
- `SONAR_JDBC_USERNAME`, `SONAR_JDBC_PASSWORD`: Database credentials.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **SonarQube UI**: Accessible via the configured port (check `docker-compose.yml` or Traefik configuration).

## Volumes
- `sonarqube-data-volume`: Stores data.
- `sonarqube-extensions-volume`: Stores plugins.
- `sonarqube-logs-volume`: Stores logs.
