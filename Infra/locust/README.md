# Locust

## 개요

이 디렉토리는 오픈 소스 부하 테스트 도구인 Locust를 실행하기 위한 Docker Compose 구성을 포함합니다. 마스터-워커 아키텍처로 구성되어 있으며, 메트릭 저장을 위해 InfluxDB와 통합됩니다.

## 서비스

- **locust-master**: 테스트를 관리하는 마스터 노드.
- **locust-worker**: 부하를 생성하는 워커 노드 (2개 레플리카로 확장됨).

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.
- InfluxDB 서비스 실행 필요 (메트릭용).

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `LOCUST_HOST_PORT`: Locust 웹 인터페이스 호스트 포트.
- `INFLUXDB_PORT`, `INFLUXDB_ORG`, `INFLUXDB_BUCKET`, `INFLUXDB_API_TOKEN`: InfluxDB 연결 정보.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

테스트를 실행하려면 마운트된 볼륨에 `locustfile.py`가 있는지 확인하십시오.

## 접속

- **Locust Web UI**: `http://localhost:${LOCUST_HOST_PORT}`

## 볼륨

- `locust-data`: `locustfile.py`를 포함하는 디렉토리 마운트.
