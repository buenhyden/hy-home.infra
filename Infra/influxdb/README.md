# InfluxDB

## 개요

이 디렉토리는 시계열 데이터베이스인 InfluxDB v2.7을 실행하기 위한 Docker Compose 구성을 포함합니다.

## 서비스

- **influxdb**: InfluxDB 서버.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `INFLUXDB_HOST_PORT`: InfluxDB 호스트 포트 (주석 처리됨, Traefik 사용).
- `INFLUXDB_PORT`: 컨테이너 포트 (기본값 8086).
- `INFLUXDB_DB_NAME`: 데이터베이스 이름.
- `INFLUXDB_USERNAME`, `INFLUXDB_PASSWORD`: 관리자 자격 증명.
- `INFLUXDB_ORG`: 조직 이름.
- `INFLUXDB_BUCKET`: 기본 버킷 이름.
- `INFLUXDB_API_TOKEN`: 관리자 API 토큰.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **InfluxDB UI**: `https://influxdb.${DEFAULT_URL}` (Traefik을 통해 접근)
- **Localhost**: 포트 매핑을 활성화한 경우 `http://localhost:${INFLUXDB_HOST_PORT}`

## 볼륨

- `influxdb-data`: InfluxDB 데이터의 영구 저장소.
