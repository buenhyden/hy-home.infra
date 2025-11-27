# Apache Airflow

## Overview
This directory contains the Docker Compose configuration for running Apache Airflow. It includes services for the API server, scheduler, DAG processor, worker, triggerer, and Flower for monitoring Celery workers.

## Services
- **airflow-apiserver**: The web server and API.
- **airflow-scheduler**: Schedules DAGs.
- **airflow-dag-processor**: Parses DAG files.
- **airflow-worker**: Executes tasks using Celery.
- **airflow-triggerer**: Runs deferrable operators.
- **flower**: Monitoring tool for Celery.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory with the necessary environment variables.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `AIRFLOW_IMAGE_NAME`: Airflow image tag (default: `apache/airflow:3.1.3`).
- `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_HOSTNAME`: Database credentials.
- `REDIS_PASSWORD`, `REDIS_NODE_NAME`, `REDIS_PORT`: Redis credentials for Celery broker.
- `AIRFLOW_UID`: User ID for file permissions.
- `AIRFLOW_HOST_PORT`: Host port for the Airflow UI.
- `FLOWER_HOST_PORT`: Host port for Flower UI.

## Usage
To start the services:
```bash
docker-compose up -d
```

To check the logs:
```bash
docker-compose logs -f
```

## Access
- **Airflow UI**: `http://localhost:${AIRFLOW_HOST_PORT}` (Check your `.env` for the actual port)
- **Flower UI**: `http://localhost:${FLOWER_HOST_PORT}`

## Volumes
- `airflow-dags`: Stores DAG files.
- `airflow-logs`: Stores execution logs.
- `airflow-config`: Stores configuration files.
- `airflow-plugins`: Stores custom plugins.
