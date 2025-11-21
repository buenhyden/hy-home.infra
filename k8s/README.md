# Kubernetes Infrastructure (Kind)

이 디렉토리는 **Kind (Kubernetes in Docker)** 클러스터 위에서 동작하는 애플리케이션 및 시스템 인프라 매니페스트를 관리합니다.
GitOps (ArgoCD) 방식을 지향하며, Kustomize를 사용하여 환경별 설정을 관리합니다.

## 📂 디렉토리 구조

```text
k8s/
├── apps/                    # 비즈니스 애플리케이션 (Frontend, Backend)
│   ├── backend/             # Python/Node.js 백엔드 서비스
│   └── frontend/            # React 프론트엔드 서비스
├── cluster-config/          # 클러스터 전역 설정
│   ├── metallb-config.yaml  # MetalLB IP Pool 설정
│   └── external-services.yaml # 외부(Docker) 서비스 연결용 Service/Endpoints
├── security/                # 보안 정책
│   ├── default-network-policy.yaml # 기본 네트워크 정책 (Deny All / Allow DNS)
│   └── kyverno/             # Kyverno 정책 (Pod Security 등)
├── system/                  # 시스템 인프라 컴포넌트
│   ├── argocd/              # ArgoCD (GitOps)
│   ├── istiod/              # Istio Control Plane
│   ├── logging/             # Loki, Promtail
│   ├── monitoring/          # Prometheus, Grafana, Tempo
│   └── ingress/             # Ingress Controllers
└── overlays/                # Kustomize Overlays (환경별 패치)
    └── kind/                # 로컬 Kind 환경용 패치
```

## 🚀 주요 컴포넌트

### 1. GitOps & 배포
- **ArgoCD**: 클러스터 상태를 Git 레포지토리와 동기화.
- **Argo Rollouts**: 블루/그린, 카나리 배포 전략 지원.

### 2. 서비스 메쉬 & 네트워킹
- **Istio**: 트래픽 관리, 보안(mTLS), 관측성 확보.
- **MetalLB**: 로컬 Kind 클러스터에 LoadBalancer IP 제공 (Docker 네트워크 대역 활용).

### 3. 관측성 (Observability)
- **Prometheus Stack**: 메트릭 수집 및 모니터링.
- **Loki**: 로그 수집 및 검색.
- **Tempo**: 분산 트레이싱.
- **Grafana**: 통합 대시보드 시각화.

### 4. 보안 (Security)
- **NetworkPolicy**: 파드 간 통신 제어 (기본 차단, 명시적 허용).
- **Kyverno**: 쿠버네티스 리소스 유효성 검사 및 변형 정책.

## 🛠 사용법

### 클러스터 생성 (Kind)
```bash
kind create cluster --config kind-config.yaml
```

### 초기 부트스트랩 (ArgoCD 설치)
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### App of Apps 패턴 적용
ArgoCD가 설치된 후, 루트 애플리케이션을 배포하여 나머지 컴포넌트를 자동 설치합니다.
```bash
kubectl apply -f system/argocd/app-of-apps.yaml
```

## ⚠️ 네트워크 구성 참고
- **MetalLB IP Pool**: `172.18.255.200-250` (Docker Bridge 네트워크 대역의 일부 사용)
- **Docker 서비스 연동**: `ExternalName` 서비스 또는 `Endpoints`를 통해 `infra_net`에 있는 Docker 컨테이너(DB, Kafka 등)와 통신합니다.
