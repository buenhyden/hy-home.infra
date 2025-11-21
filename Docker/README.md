# Docker Infrastructure

이 디렉토리는 로컬 개발 및 테스트를 위한 **Docker Compose 기반의 인프라 환경**을 정의합니다.
Kubernetes(Kind) 클러스터 외부에서 동작해야 하거나, 데이터 지속성이 중요한 Stateful 서비스들을 이곳에서 관리합니다.

## 📂 디렉토리 구조

```text
Docker/
├── docker-compose.yml       # 전체 인프라를 실행하는 메인 Compose 파일
├── .env                     # 환경 변수 (포트, 비밀번호, 버전 등)
├── configs/                 # 서비스별 설정 파일 (Elasticsearch, Postgres, Redis 등)
├── secrets/                 # 민감 정보 (비밀번호 파일 등)
├── Infra/                   # 인프라 서비스별 Compose 및 설정
│   ├── airflow/             # Airflow (Workflow Engine)
│   ├── alloy/               # Grafana Alloy (Observability Agent)
│   ├── cadvisor/            # cAdvisor (Container Monitoring)
│   ├── elasticsearch/       # Elasticsearch (Legacy)
│   ├── harbor/              # Harbor (Container Registry)
│   ├── influxdb/            # InfluxDB (Time Series DB)
│   ├── kafka/               # Kafka Cluster (KRaft mode)
│   ├── keycloak/            # Keycloak (Identity Provider)
│   ├── minio/               # MinIO (S3 Compatible Storage)
│   ├── mongodb/             # MongoDB
│   ├── n8n/                 # n8n (Workflow Automation)
│   ├── ollama/              # Ollama (LLM Inference)
│   ├── opensearch/          # OpenSearch Cluster (Search Engine)
│   ├── postgresql/          # PostgreSQL HA (Patroni + Etcd + HAProxy)
│   ├── redis-cluster/       # Redis Cluster
│   ├── sonarqube/           # SonarQube (Code Quality)
│   ├── supabase/            # Supabase (Backend as a Service)
│   ├── traefik/             # Traefik (Reverse Proxy)
│   └── wikijs/              # Wiki.js (Documentation)
└── Projects/                # (Optional) 개발 중인 애플리케이션 프로젝트
```

## 🚀 주요 서비스 구성

### 1. 데이터베이스 & 메시지 큐
- **PostgreSQL HA**: Patroni, Etcd, HAProxy를 이용한 고가용성 클러스터.
- **Redis Cluster**: 3 Master + 3 Slave 구조의 Redis 클러스터.
- **Kafka**: Zookeeper 없는 KRaft 모드 클러스터 + Schema Registry + Connect + UI.
- **MinIO**: S3 호환 객체 스토리지.
- **MongoDB**: NoSQL 데이터베이스.

### 2. 검색 & AI
- **OpenSearch**: 3노드 클러스터 + Dashboards.
- **Ollama**: 로컬 LLM 실행 환경 (GPU 지원 설정 포함).
- **Qdrant**: Vector Database (RAG 구현용).

### 3. 관측성 (Observability)
- **Grafana Alloy**: 메트릭, 로그, 트레이스 수집 에이전트.
- **Prometheus, Grafana, Loki, Tempo**: (일부는 k8s로 이동 중, Docker 내에도 구성 가능)

### 4. 도구 & 유틸리티
- **n8n**: 워크플로우 자동화 툴.
- **Harbor**: 프라이빗 컨테이너 레지스트리.
- **SonarQube**: 코드 정적 분석.
- **Traefik**: 도커 컨테이너 라우팅 및 로드밸런싱.

## 🛠 사용법

### 전체 실행
```bash
docker compose up -d
```

### 특정 서비스 그룹 실행
`docker-compose.yml`의 `include` 기능을 활용하여 모듈화되어 있습니다.
개별 폴더로 이동하여 실행하거나, 메인에서 필요한 서비스만 주석 해제하여 사용할 수 있습니다.

```bash
# 예: PostgreSQL만 실행
cd Infra/postgresql
docker compose up -d
```

## ⚠️ 주의사항
- **네트워크**: 모든 서비스는 `infra_net` (172.19.0.0/16) 네트워크를 공유하여 서로 통신합니다.
- **볼륨**: 데이터는 로컬 볼륨 또는 바인드 마운트를 통해 영구 저장됩니다.
- **리소스**: 전체 실행 시 많은 CPU/RAM이 필요하므로 필요한 서비스만 선별하여 실행하는 것을 권장합니다.
