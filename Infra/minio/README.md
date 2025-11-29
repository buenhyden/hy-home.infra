# MinIO

## 개요

이 디렉토리는 고성능 S3 호환 객체 스토리지인 MinIO를 실행하기 위한 Docker Compose 구성을 포함합니다. 초기 버킷 생성을 위한 헬퍼 컨테이너도 포함되어 있습니다.

## 서비스

- **minio**: MinIO 서버.
- **minio-create-buckets**: 시작 시 버킷(`tempo-bucket`, `loki-bucket`, `cdn-bucket`)을 자동으로 생성하는 유틸리티.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `MINIO_HOST_PORT`: S3 API 호스트 포트 (Traefik 사용 시 주석 처리됨).
- `MINIO_CONSOLE_HOST_PORT`: MinIO 콘솔 호스트 포트 (Traefik 사용 시 주석 처리됨).
- `MINIO_PORT`, `MINIO_CONSOLE_PORT`: 컨테이너 포트.

또한 민감한 데이터는 Docker secrets를 사용합니다:

- `minio_root_user`
- `minio_root_password`

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

Traefik을 통해 다음 도메인으로 접근 가능합니다 (`.env`의 `DEFAULT_URL` 설정에 따라 다름):

- **MinIO Console**: `https://minio-console.${DEFAULT_URL}`
- **S3 API**: `https://minio.${DEFAULT_URL}`

## 볼륨

- `minio-data`: 객체 데이터의 영구 저장소.
