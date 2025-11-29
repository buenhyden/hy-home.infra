# Apache Kafka (KRaft Mode)

## 개요

이 디렉토리는 KRaft 모드(ZooKeeper 없음)에서 3노드 Apache Kafka 클러스터를 실행하기 위한 Docker Compose 구성을 포함합니다. Schema Registry, Kafka Connect, REST Proxy, Kafka UI, Kafka Exporter를 포함합니다.

## 서비스

- **kafka-1, kafka-2, kafka-3**: 브로커 및 컨트롤러 역할을 모두 수행하는 3개의 Kafka 브로커.
- **schema-registry**: Confluent Schema Registry.
- **kafka-connect**: 분산형 Kafka Connect.
- **kafka-rest-proxy**: Kafka용 REST Proxy.
- **kafka-ui**: Kafka 클러스터 관리를 위한 웹 UI (Provectus).
- **kafka-exporter**: Kafka 메트릭을 위한 Prometheus Exporter.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `KAFKA_CLSUTER_ID`: Kafka 클러스터의 고유 ID.
- `KAFKA_CLSUTER_NAME`: UI에 표시될 클러스터 이름.
- `KAFKA_CONTROLLER_*_HOST_PORT`: 브로커 접근을 위한 포트.
- `SCHEMA_REGISTRY_PORT`: Schema Registry 포트.
- `KAFKA_CONNECT_PORT`: Kafka Connect 포트.
- `KAFKA_REST_PROXY_PORT`: REST Proxy 포트.
- `KAFKA_UI_PORT`: Kafka UI 포트.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

Traefik을 통해 다음 도메인으로 접근 가능합니다 (`.env`의 `DEFAULT_URL` 설정에 따라 다름):

- **Kafka UI**: `https://kafka-ui.${DEFAULT_URL}`
- **Schema Registry**: `https://schema-registry.${DEFAULT_URL}`
- **Kafka Connect**: `https://kafka-connect.${DEFAULT_URL}`
- **REST Proxy**: `https://kafka-rest.${DEFAULT_URL}`

로컬 포트 포워딩을 사용하는 경우:

- **Kafka UI**: `http://localhost:${KAFKA_UI_HOST_PORT}` (포트 매핑이 활성화된 경우)

## 볼륨

- `kafka-1-data`, `kafka-2-data`, `kafka-3-data`: Kafka 브로커의 영구 저장소.
- `kafka-connect-data`: Kafka Connect의 영구 저장소.
