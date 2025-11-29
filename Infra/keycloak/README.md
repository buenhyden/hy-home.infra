# Keycloak

## 개요

이 디렉토리는 Keycloak(ID 및 액세스 관리)과 MailHog(이메일 테스트)를 실행하기 위한 Docker Compose 구성을 포함합니다.

## 서비스

- **keycloak**: ID 및 액세스 관리 서버.
- **mailhog**: 이메일 테스트를 위한 SMTP 서버 및 웹 UI.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.
- 외부 PostgreSQL 데이터베이스 (`.env`에 설정됨).

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `KEYCLOAK_ADMIN`, `KEYCLOAK_ADMIN_PASSWORD`: 관리자 계정.
- `KEYCLOAK_DATABASE`, `KEYCLOAK_DB_USER`, `KEYCLOAK_DB_PASSWORD`: 데이터베이스 설정.
- `POSTGRES_HOSTNAME`, `POSTGRES_WRITE_PORT`: 데이터베이스 호스트 및 포트.
- `DEFAULT_URL`: 기본 도메인 URL.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

Traefik을 통해 다음 도메인으로 접근 가능합니다:

- **Keycloak**: `https://keycloak.${DEFAULT_URL}`
- **MailHog**: `https://mail.${DEFAULT_URL}`

## 참고 사항

- `start-dev` 명령을 사용하지만, 외부 PostgreSQL과 연결되어 데이터가 유지됩니다.
- Traefik을 통해 HTTPS 및 라우팅이 처리됩니다.
