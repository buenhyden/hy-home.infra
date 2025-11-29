# Harbor

## 개요

이 디렉토리는 오픈 소스 클라우드 네이티브 레지스트리 프로젝트인 Harbor를 실행하기 위한 Docker Compose 구성을 포함합니다. Bitnami 이미지를 사용하며 PostgreSQL 및 Valkey(Redis)와 통합됩니다.

## 서비스

- **harbor-core**: Harbor의 핵심 서비스.
- **harbor-registry**: Docker 레지스트리 서비스.
- **harbor-registryctl**: 레지스트리 제어.
- **harbor-portal**: Harbor 웹 UI.
- **harbor-jobservice**: 비동기 작업 처리.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.
- 외부 PostgreSQL 및 Valkey(Redis) 서비스 실행 필요 (`.env`에 설정됨).

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `HARBOR_PORT`: Harbor 서비스 포트.
- `HARBOR_PASSWORD`: 관리자 비밀번호.
- `HARBOR_CORE_SECRET`, `HARBOR_JOBSERVICE_SECRET`, `HARBOR_REGISTRY_HTTP_SECRET`: 내부 통신을 위한 시크릿.
- `POSTGRES_HOSTNAME`, `POSTGRES_PORT`, `POSTGRES_PASSWORD`: 데이터베이스 연결 정보.
- `VALKEY_STANDALONE_HOSTNAME`, `VALKEY_PORT`, `VALKEY_PASSWORD`: Redis 연결 정보.
- `DEFAULT_CICD_DIR`: 영구 저장을 위한 기본 디렉토리.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **Harbor Portal**: `http://localhost:${HARBOR_PORT}` (`.env` 파일의 실제 포트 확인)

## 볼륨

- `harbor-registry-data-volume`: 레지스트리 데이터 저장.
- `harbor-core-data-volume`: 코어 데이터 저장.
- `harbor-jobservice-logs-volume`: 작업 로그 저장.
- registry, registryctl, core, jobservice를 위한 설정 볼륨들.
