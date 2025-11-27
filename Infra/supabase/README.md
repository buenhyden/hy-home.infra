# Supabase

## Overview
This directory contains the Docker Compose configuration for running a self-hosted Supabase stack. It includes all core services like Auth, Realtime, Storage, and the Studio dashboard.

## Services
- **studio**: Supabase Dashboard.
- **kong**: API Gateway.
- **auth**: Authentication service (GoTrue).
- **rest**: PostgREST service.
- **realtime**: Realtime server.
- **storage**: Storage API.
- **imgproxy**: Image transformation service.
- **meta**: Postgres meta service.
- **functions**: Edge Functions runtime.
- **analytics**: Analytics service (Logflare).
- **db**: PostgreSQL database (customized for Supabase).
- **vector**: Vector log collector.
- **supavisor**: Connection pooler.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on a large number of environment variables (defined in `.env`), including:
- **Keys**: `ANON_KEY`, `SERVICE_ROLE_KEY`, `JWT_SECRET`.
- **Database**: `POSTGRES_PASSWORD`, `POSTGRES_DB`.
- **Ports**: `KONG_HTTP_PORT`, `KONG_HTTPS_PORT`.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **Supabase Studio**: `http://localhost:3000` (default, check `docker-compose.yml` for mapped port if different).
- **API Gateway**: `http://localhost:${KONG_HTTP_PORT}`

## Volumes
- Multiple volumes are used for persisting database, storage, and configuration data.
