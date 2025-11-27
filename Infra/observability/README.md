# Observability Stack

## Overview
This directory contains the Docker Compose configuration for a comprehensive observability stack, including metrics, logs, and traces.

## Services
- **prometheus**: Metrics storage and querying.
- **loki**: Log aggregation system.
- **tempo**: Distributed tracing backend.
- **grafana**: Visualization and analytics platform.
- **alloy**: OpenTelemetry collector (Grafana Alloy).
- **cadvisor**: Container metrics collector.
- **alertmanager**: Handles alerts sent by Prometheus.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The stack relies on the following environment variables (defined in `.env`):
- **Ports**: `PROMETHEUS_HOST_PORT`, `LOKI_HOST_PORT`, `TEMPO_HOST_PORT`, `GRAFANA_HOST_PORT`, `ALLOY_HOST_PORT`, `ALERTMANAGER_HOST_PORT`.
- **Credentials**: `GRAFANA_ADMIN_USERNAME`, `GRAFANA_ADMIN_PASSWORD`.
- **Alerting**: `SMTP_USERNAME`, `SMTP_PASSWORD`, `SLACK_ALERTMANAGER_WEBHOOK_URL`.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **Grafana**: `http://localhost:${GRAFANA_HOST_PORT}` (Login with configured admin credentials)
- **Prometheus**: `http://localhost:${PROMETHEUS_HOST_PORT}`
- **Alertmanager**: `http://localhost:${ALERTMANAGER_HOST_PORT}`

## Volumes
- Persistent volumes are configured for Prometheus, Loki, Tempo, Grafana, and Alertmanager data.
