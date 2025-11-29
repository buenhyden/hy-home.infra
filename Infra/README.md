# Docker Infrastructure & Projects

## 개요

이 저장소는 전체 인프라 및 개발 프로젝트를 위한 Docker Compose 구성을 포함합니다. 크게 두 가지 섹션으로 구성됩니다:

- **Docker/Infra**: 인프라 서비스 (데이터베이스, 메시지 브로커, 관측성 도구 등).
- **Docker/Projects**: 개발 프로젝트 템플릿 및 환경.

## 필수 조건

- **Docker**: Docker Engine이 설치되어 있어야 합니다.
- **Docker Compose**: Docker Compose가 설치되어 있어야 합니다.
- **환경 변수**: `Docker/Infra` 위치에 `.env` 파일이 **필수**입니다. 이 파일은 서비스 실행에 필요한 모든 환경 변수(포트, 비밀번호, 경로 등)를 포함합니다.

## 디렉토리 구조

### Docker/Infra

인프라 서비스는 기능별로 분류되어 있습니다. 각 디렉토리는 `docker-compose.yml`과 구체적인 지침이 담긴 `README.md`를 포함합니다.

| 서비스 | 설명 |
| :--- | :--- |
| [airflow](./airflow) | 워크플로우 오케스트레이션을 위한 Apache Airflow. |
| [cassandra](./cassandra) | Apache Cassandra NoSQL 데이터베이스. |
| [harbor](./harbor) | Harbor 컨테이너 레지스트리. |
| [influxdb](./influxdb) | 시계열 데이터베이스 InfluxDB. |
| [kafka](./kafka) | 스키마 레지스트리, 커넥트, UI를 포함한 Apache Kafka (KRaft 모드). |
| [keycloak](./keycloak) | Keycloak 자격 증명 및 액세스 관리. |
| [ksql](./ksql) | 스트림 처리를 위한 ksqlDB. |
| [locust](./locust) | 부하 테스트를 위한 Locust. |
| [minio](./minio) | MinIO 객체 스토리지 (S3 호환). |
| [mongodb](./mongodb) | Mongo Express를 포함한 MongoDB 레플리카 셋. |
| [n8n](./n8n) | n8n 워크플로우 자동화 도구. |
| [neo4j](./neo4j) | Neo4j 그래프 데이터베이스. |
| [nginx](./nginx) | Nginx 웹 서버 및 리버스 프록시. |
| [oauth2-proxy](./oauth2-proxy) | OAuth2 인증을 위한 프록시 서비스. |
| [observability](./observability) | 풀 스택 관측성: Prometheus, Loki, Tempo, Grafana, Alloy. |
| [ollama](./ollama) | Qdrant 및 Open WebUI를 포함한 로컬 LLM 실행기. |
| [opensearch](./opensearch) | OpenSearch 제품군 (검색 + 대시보드). |
| [postgresql](./postgresql) | PostgreSQL 고가용성 클러스터 (Patroni + Etcd + HAProxy). |
| [redis-cluster](./redis-cluster) | RedisInsight를 포함한 Redis 클러스터 (6 노드). |
| [sonarqube](./sonarqube) | 코드 품질 검사를 위한 SonarQube. |
| [storybook](./storybook) | UI 개발을 위한 Storybook 설정. |
| [supabase](./supabase) | 셀프 호스팅 Supabase 스택. |
| [syncthing](./syncthing) | 파일 동기화를 위한 Syncthing. |
| [traefik](./traefik) | Traefik 리버스 프록시 및 로드 밸런서. |
| [valkey](./valkey) | Valkey (Redis 포크) 클러스터 및 단독형. |

### Docker/Projects

다양한 언어와 프레임워크를 위한 개발 환경입니다.

| 프로젝트 | 설명 |
| :--- | :--- |
| [Django](../Projects/Django) | Python Django 개발 환경. |
| [ExpressJS](../Projects/ExpressJS) | Node.js Express 개발 환경. |
| [FastAPI](../Projects/FastAPI) | Python FastAPI 개발 환경. |
| [Gradle](../Projects/Gradle) | Java Spring Boot (Gradle) 환경. |
| [Maven](../Projects/Maven) | Java Spring Boot (Maven) 환경. |
| [NestJS](../Projects/NestJS) | Node.js NestJS 개발 환경. |
| [NextJS](../Projects/NextJS) | Node.js NextJS 개발 환경. |
| [ReactJS](../Projects/ReactJS) | ReactJS (Vite) 개발 환경. |

## 시작하기

1. **환경 설정**:
   예제 환경 파일(있는 경우)을 복사하거나 `Docker/Infra`에 필요한 변수가 포함된 `.env` 파일을 생성합니다.

2. **서비스 실행**:
   해당 서비스 디렉토리로 이동하여 다음을 실행합니다:

   ```bash
   cd Docker/Infra/redis-cluster
   docker-compose up -d
   ```

3. **프로젝트 실행**:
   해당 프로젝트 디렉토리로 이동하여 다음을 실행합니다:

   ```bash
   cd Docker/Projects/ReactJS
   docker-compose up -d
   ```

## 네트워크

대부분의 서비스는 공유 Docker 네트워크(예: `infra_net`, `nt-databases`, `nt-webserver`)를 통해 연결되어 컨테이너 간 통신이 가능합니다. `docker-compose.yml` 파일의 네트워크 설정이 요구 사항과 일치하는지 확인하십시오.
