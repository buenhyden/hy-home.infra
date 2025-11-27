# Traefik

## Overview

This directory contains the Docker Compose configuration for running Traefik, a modern HTTP reverse proxy and load balancer.

## Services

- **traefik**: The Traefik proxy.

## Prerequisites

- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration

The service relies on the following environment variables (defined in `.env`):

- `TRAEFIK_PORT`: Port for the Traefik Dashboard.
- `DEFAULT_WEB_SERVER_DIR`: Directory for configuration and certs.

## Usage

To start the services:

```bash
docker-compose up -d
```

## Access

- **HTTP**: Port 80
- **HTTPS**: Port 443
- **Dashboard**: `http://localhost:${TRAEFIK_PORT}`

## Volumes

- `traefik-conf-volume`: Configuration files.
- `traefik-certs-volume`: SSL certificates.
- `traefik-log-volume`: Logs.

```bash
mkcert -key-file key.pem -cert-file cert.pem localhost 127.0.0.1 ::1 *.localhost hy-home.local *.hy-home.local *.minio.hy-home.local
```

mkcert에서 와일드카드는 1단계만 적용

# 도커를 이용한 해시 생성 (공통)

```
$ docker run --rm httpd:alpine htpasswd -nb admin secure_password
```