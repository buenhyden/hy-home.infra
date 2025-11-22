# hy-home-infra

이 프로젝트는 **로컬 하이브리드 인프라 환경**을 구축하기 위한 저장소입니다.
데이터 및 Stateful 서비스는 **Docker Compose**로, 애플리케이션 및 Stateless 서비스는 **Kubernetes (Kind)** 로 분리하여 관리합니다.

## 📚 문서 바로가기

| 영역 | 설명 | 링크 |
| --- | --- | --- |
| **Docker** | 데이터베이스, 메시지 큐, 검색엔진 등 Stateful 인프라 | [Docker/README.md](Docker/README.md) |
| **Kubernetes** | 애플리케이션, 서비스 메쉬, GitOps, 모니터링 등 | [k8s/README.md](k8s/README.md) |

## 🏗 아키텍처 개요

### 1. 하이브리드 구성 이유
- **Docker**: 데이터베이스(Postgres, Redis 등)와 같이 영속성이 중요하고 무거운 서비스는 Docker Compose로 호스트 레벨에서 안정적으로 실행합니다.
- **Kubernetes (Kind)**: 마이크로서비스 애플리케이션, CI/CD, 서비스 메쉬 등 클라우드 네이티브 기술 스택을 학습하고 검증합니다.

### 2. 네트워크 토폴로지
두 환경은 서로 다른 네트워크 대역을 사용하지만, 라우팅을 통해 통신합니다.

- **Docker Network (`infra_net`)**: `172.19.0.0/16`
  - 모든 Docker 컨테이너가 이 네트워크에 배치됩니다.
- **Kind Network**: `172.18.0.0/16` (Docker Desktop 기본)
  - **MetalLB**: `172.18.255.200 - 172.18.255.250` 범위를 사용하여 K8s 서비스에 외부 IP를 할당합니다.

### 3. 주요 기술 스택

| 계층 | 구성요소 | 배치 |
| --- | --- | --- |
| **데이터** | PostgreSQL HA, Redis Cluster, Kafka, OpenSearch, MinIO | **Docker** |
| **관측성** | Grafana Alloy, Prometheus, Loki, Tempo | **Kind** (일부 Docker) |
| **네트워킹** | Istio, MetalLB, Traefik | **Kind** / **Docker** |
| **GitOps** | ArgoCD, Argo Rollouts | **Kind** |
| **AI/ML** | Ollama (LLM), Qdrant (Vector DB) | **Docker** |
| **자동화** | n8n, Airflow | **Docker** |

## 🚀 시작하기

### 필수 요구사항
- Docker Desktop (Windows/Mac)
- Kubernetes CLI (`kubectl`)
- Kind (`kind`)
- Helm (`helm`)

### 설치 순서
1. **Docker 인프라 실행**: `Docker/` 디렉토리에서 필요한 서비스 실행
2. **Kind 클러스터 생성**: `k8s/` 디렉토리의 설정으로 클러스터 생성
3. **ArgoCD 배포**: GitOps를 통해 K8s 리소스 자동 동기화

자세한 내용은 각 디렉토리의 README를 참고하세요.
