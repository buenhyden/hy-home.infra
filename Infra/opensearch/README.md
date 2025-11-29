# OpenSearch

## 개요

이 디렉토리는 분산 검색 및 분석 제품군인 OpenSearch를 실행하기 위한 Docker Compose 구성을 포함합니다. OpenSearch Dashboards와 Exporter도 포함되어 있습니다.

## 서비스

- **opensearch-node1**: 단일 노드 OpenSearch 인스턴스 (Cluster Manager + Data + Ingest).
- **opensearch-dashboards**: OpenSearch용 웹 인터페이스.
- **opensearch-exporter**: OpenSearch 메트릭을 위한 Prometheus Exporter.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `ES_HOST_1_PORT`: OpenSearch API 호스트 포트 (Traefik 사용 시 주석 처리됨).
- `KIBANA_HOST_PORT`: OpenSearch Dashboards 호스트 포트 (Traefik 사용 시 주석 처리됨).
- `ES_EXPORTER_HOST_PORT`: 메트릭 호스트 포트.
- `ELASTIC_USERNAME`, `ELASTIC_PASSWORD`: 관리자 자격 증명.
- `OPENSEARCH_JAVA_OPTS`: JVM 힙 설정.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

Traefik을 통해 다음 도메인으로 접근 가능합니다 (`.env`의 `DEFAULT_URL` 설정에 따라 다름):

- **OpenSearch Dashboards**: `https://opensearch-dashboard.${DEFAULT_URL}`
- **OpenSearch API**: `https://opensearch.${DEFAULT_URL}` (자체 서명 인증서 사용)

## 볼륨

- `opensearch-data1`: OpenSearch 데이터의 영구 저장소.
