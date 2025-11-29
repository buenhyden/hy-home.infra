# OAuth2 Proxy

## 개요

이 디렉토리는 OAuth2 Proxy를 실행하기 위한 Docker Compose 구성을 포함합니다. 이는 Keycloak과 같은 ID 공급자(IdP)와 통합하여 애플리케이션에 대한 인증을 제공합니다.

## 서비스

- **oauth2-proxy**: OAuth2 인증 프록시.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.
- Keycloak과 같은 외부 IdP 설정.
- `oauth2-proxy.cfg` 설정 파일.
- SSL 인증서 (`certs/rootCA.pem`).

## 설정

이 서비스는 주로 `oauth2-proxy.cfg` 파일과 환경 변수를 통해 구성됩니다.

- `SSL_CERT_FILE`: 루트 CA 인증서 경로.
- `OAUTH2_PROXY_PORT`: 서비스 포트.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

Traefik을 통해 다음 도메인으로 접근 가능합니다:

- **Auth Endpoint**: `https://auth.${DEFAULT_URL}`

## 볼륨

- `./oauth2-proxy.cfg`: 설정 파일.
- `./certs/rootCA.pem`: SSL 루트 인증서.
