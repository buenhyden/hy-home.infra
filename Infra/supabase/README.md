# Supabase

## 개요

이 디렉토리는 자체 호스팅 Supabase 스택을 실행하기 위한 Docker Compose 구성을 포함합니다. Auth, Realtime, Storage, Studio 대시보드와 같은 모든 핵심 서비스를 포함합니다.

## 서비스

- **studio**: Supabase 대시보드.
- **kong**: API 게이트웨이.
- **auth**: 인증 서비스 (GoTrue).
- **rest**: PostgREST 서비스.
- **realtime**: 리얼타임 서버.
- **storage**: 스토리지 API.
- **imgproxy**: 이미지 변환 서비스.
- **meta**: Postgres 메타 서비스.
- **functions**: 엣지 함수 런타임.
- **analytics**: 분석 서비스 (Logflare).
- **db**: PostgreSQL 데이터베이스 (Supabase용 커스텀).
- **vector**: 벡터 로그 수집기.
- **supavisor**: 연결 풀러.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음을 포함하여 `.env`에 정의된 다수의 환경 변수를 사용합니다:

- **키**: `ANON_KEY`, `SERVICE_ROLE_KEY`, `JWT_SECRET`.
- **데이터베이스**: `POSTGRES_PASSWORD`, `POSTGRES_DB`.
- **포트**: `KONG_HTTP_PORT`, `KONG_HTTPS_PORT`.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **Supabase Studio**: `http://localhost:3000` (기본값, 변경된 경우 `docker-compose.yml` 확인).
- **API Gateway**: `http://localhost:${KONG_HTTP_PORT}`

## 볼륨

- 데이터베이스, 스토리지, 설정 데이터의 영구 보존을 위해 다수의 볼륨이 사용됩니다.
