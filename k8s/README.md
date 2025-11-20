# Kind

## 2. 공통 준비 (클러스터, StorageClass, MetalLB)

### 2-1. 컨텍스트 및 네임스페이스

```bash
# docker-desktop 컨텍스트 사용
kubectl config use-context docker-desktop

# 기본 네임스페이스들
kubectl create namespace observability
kubectl create namespace istio-system
kubectl create namespace security
kubectl create namespace argo
kubectl create namespace airflow
kubectl create namespace n8n
kubectl create namespace hy-home
```

#### PodSecurity 라벨 (restricted)

```yaml
# namespaces/hy-home-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hy-home
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: baseline
```

### 2-2. StorageClass(local-path-provisioner)

Docker Desktop Kubernetes에는 기본 StorageClass가 있을 수도 있지만, **명시적으로 local-path-provisioner를 설치**하는 편이 안전함. Rancher의 local-path-provisioner를 그대로 사용하는 방식이 가장 단순.

```bash
kubectl apply -f \
  https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.32/deploy/local-path-storage.yaml
```

기본 StorageClass로 설정:

```bash
kubectl patch storageclass local-path \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

이제 Loki/Tempo/Prometheus/Airflow/n8n PVC에서 `storageClassName: local-path` 를 사용.

### 2-3. MetalLB IP 풀 설정 (172.18.0.0/16 내부)

```bash
helm repo add metallb https://metallb.github.io/metallb
helm repo update

helm install metallb metallb/metallb \
  -n metallb-system --create-namespace
```

```yaml
# metallb/ipaddresspool.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: hy-home-pool
  namespace: metallb-system
spec:
  addresses:
    - 172.18.255.1-172.18.255.50  # kind 네트워크 안의 상단 대역
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: hy-home-l2adv
  namespace: metallb-system
spec:
  ipAddressPools:
    - hy-home-pool
```

---

## 4. Kubernetes 인프라: Observability / Mesh / Policy / GitOps

### 4-1. Grafana Alloy (DaemonSet + 일부 sidecar)

Helm Repo 추가:

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install alloy grafana/alloy \
  -n observability \
  -f kube/alloy/values.yaml
```

`kube/alloy/values.yaml` (핵심만):

```yaml
controller:
  type: daemonset
  daemonset:
    podAnnotations:
      sidecar.istio.io/inject: "false"
    resources:
      requests:
        cpu: 100m
        memory: 256Mi
  config:
    inline: |
      prometheus.receiver "kube" {}
      loki.write "loki" {
        endpoint {
          url = "http://loki-gateway.observability.svc.cluster.local/loki/api/v1/push"
        }
      }
      otlp.write "tempo" {
        endpoint {
          url = "http://tempo-distributor.observability.svc.cluster.local:4317"
        }
      }
      prometheus.exporter "self" {}

      # K8s 메트릭/로그 수집 파이프라인 (요약)
      discovery.kubernetes "pods" {}
      loki.source.kubernetes "pods" {
        targets = discovery.kubernetes.pods.targets
      }
      loki.relabel "kube" {
        forward_to = [loki.write.loki.receiver]
      }
```

백엔드/프론트 일부 Pod는 Alloy sidecar를 붙여 OTLP(Trace)를 전송하도록 설정 가능:

```yaml
# 예: backend Rollout template에 sidecar 추가
- name: alloy-sidecar
  image: grafana/alloy:latest
  args: ["run", "/etc/alloy/sidecar.alloy"]
  volumeMounts:
    - name: alloy-config
      mountPath: /etc/alloy
```

---

### 4-2. Loki & Tempo (Helm, MinIO 백엔드)

Loki/Tempo Helm 차트는 Grafana repo에 있으며, S3 호환 스토리지를 backend로 설정할 수 있음.

```bash
helm install loki grafana/loki \
  -n observability \
  -f kube/loki/values.yaml

helm install tempo grafana/tempo \
  -n observability \
  -f kube/tempo/values.yaml
```

`kube/loki/values.yaml` (MinIO 사용 예시):

```yaml
loki:
  storage:
    type: s3
    s3:
      endpoint: http://minio.infra.svc.cluster.local:9000
      bucketnames: loki
      access_key_id: ${MINIO_ACCESS_KEY}
      secret_access_key: ${MINIO_SECRET_KEY}
      s3forcepathstyle: true
  schemaConfig:
    configs:
      - from: "2025-01-01"
        store: boltdb-shipper
        object_store: s3
        schema: v13
        index:
          prefix: index_
          period: 24h
```

MinIO 자격증명은 **K8s Secret**으로 만들어서 `envFrom.secretRef` 등으로 주입.

---

### 4-3. kube-prometheus-stack (Prometheus + Grafana)

Helm repo:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install kps prometheus-community/kube-prometheus-stack \
  -n observability \
  -f kube/kube-prometheus-stack/values.yaml
```

`kube/kube-prometheus-stack/values.yaml` (요약):

```yaml
prometheus:
  prometheusSpec:
    scrapeInterval: 15s
    enableAdminAPI: false
    podMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelectorNilUsesHelmValues: false
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: local-path
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 20Gi
    additionalScrapeConfigs:
      # Docker Exporter 스크랩
      - job_name: "docker-postgres-exporter"
        static_configs:
          - targets: ["host.docker.internal:9187"]
            labels:
              instance: "docker-postgres"
      - job_name: "docker-redis-exporter"
        static_configs:
          - targets: ["host.docker.internal:9121"]
            labels:
              instance: "docker-redis"
```

---

### 4-4. Kyverno + 정책 (non-root, latest 금지, default deny)

Helm repo:

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

예시 정책 – latest 태그 금지:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
spec:
  validationFailureAction: enforce
  rules:
    - name: check-latest
      match:
        any:
          - resources:
              kinds: ["Pod"]
      validate:
        message: "이미지 latest 태그 사용 금지"
        pattern:
          spec:
            containers:
              - image: "!*:latest"
```

non-root 컨테이너 강제, hostPath 금지 정책도 비슷하게 추가.

---

### 4-5. Istio + Ingress Gateway

실서비스와 비슷하게 Helm으로 설치.

```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system --set profile=default

helm install istio-ingress istio/gateway -n istio-system \
  --set service.type=LoadBalancer
```

`istio-ingress` Service는 MetalLB IP를 하나 받게 되고, 이를 도메인(hy-home.local 등)에 매핑해서 사용.

---

### 4-6. cert-manager (self-signed Issuer)

Helm repo:

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  -n cert-manager --create-namespace \
  --set crds.enabled=true
```

self-signed Issuer:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: dev-selfsigned
spec:
  selfSigned: {}
```

Ingress에 `cert-manager.io/cluster-issuer: dev-selfsigned`로 TLS 자동 발급.

---

### 4-7. GitOps: Argo CD + Rollouts + Image Updater + Notifications

Helm repo:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Argo CD
helm install argocd argo/argo-cd -n argo \
  -f kube/argocd/values.yaml

# Argo Rollouts
helm install argo-rollouts argo/argo-rollouts -n argo

# Image Updater
helm install argo-image-updater argo/argocd-image-updater -n argo
```

Argo CD Notifications는 `argocd-notifications` 서브차트 또는 ConfigMap/Secret로 설정:

```yaml
# kube/argocd/notifications-cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argo
data:
  service.slack: |
    token: $slack-token
  trigger.on-sync-status: |
    - when: app.status.operationState.phase in ['Failed', 'Error']
      send: [slack]
```

Secret에 Slack 토큰 저장:

```bash
kubectl -n argo create secret generic argocd-notifications-secret \
  --from-literal=slack-token="xoxb-..."
```

---

## 5. 애플리케이션: Backend / Frontend / Airflow / n8n

### 5-1. hy-home-infra 리포 구조 제안

```text
hy-home-infra/
  clusters/
    docker-desktop/
      infra/
        metallb/
        istio/
        cert-manager/
        observability/   # alloy, loki, tempo, kps
        security/        # kyverno, networkpolicy
        argo/
      apps/
        backend/
        frontend/
        airflow/
        n8n/
  apps/
    backend/
      base/
      overlays/
        docker-desktop/
    frontend/
      base/
      overlays/
        docker-desktop/
```

Argo CD app-of-apps:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: hy-home-root
  namespace: argo
spec:
  project: default
  source:
    repoURL: https://github.com/buenhyden/hy-home-infra.git
    targetRevision: main
    path: clusters/docker-desktop
  destination:
    server: https://kubernetes.default.svc
    namespace: argo
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

### 5-2. Backend (Python, Argo Rollouts + HPA + anti-affinity)

`apps/backend/base/rollout.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: hy-home-backend
  labels:
    app: hy-home-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hy-home-backend
  strategy:
    canary:
      canaryService: hy-home-backend-canary
      stableService: hy-home-backend
      trafficRouting:
        istio:
          virtualService:
            name: hy-home-backend-vs
            routes:
              - primary
      steps:
        - setWeight: 20
        - pause: {duration: 60}
        - setWeight: 50
        - pause: {duration: 120}
        - setWeight: 100
  template:
    metadata:
      labels:
        app: hy-home-backend
      annotations:
        sidecar.istio.io/inject: "true"
    spec:
      containers:
        - name: app
          image: ghcr.io/buenhyden/hy-home-backend:1.0.0
          ports:
            - containerPort: 8000
          envFrom:
            - secretRef:
                name: backend-secrets
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchLabels:
                    app: hy-home-backend
                topologyKey: kubernetes.io/hostname
```

HPA:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hy-home-backend-hpa
  namespace: hy-home
spec:
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    name: hy-home-backend
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

백엔드 DB 접속 Secret (비밀번호는 여기 말고 `kubectl create secret` 명령으로 주입):

```bash
kubectl -n hy-home create secret generic backend-secrets \
  --from-literal=DATABASE_URL='postgresql://hy:***@postgres-primary:5432/hy_home' \
  --from-literal=REDIS_URL='redis://:***@redis-node-1:7000'
```

> GitOps에서는 이 Secret을 SOPS로 암호화 후 리포에 저장하는 형태로 운영.

---

### 5-3. Frontend (React, Deployment + HPA)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hy-home-frontend
  namespace: hy-home
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hy-home-frontend
  template:
    metadata:
      labels:
        app: hy-home-frontend
      annotations:
        sidecar.istio.io/inject: "true"
    spec:
      containers:
        - name: frontend
          image: ghcr.io/buenhyden/hy-home-frontend:1.0.0
          ports:
            - containerPort: 3000
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchLabels:
                    app: hy-home-frontend
                topologyKey: kubernetes.io/hostname
```

HPA는 backend와 비슷하게 설정.

Istio VirtualService/ Gateway:

```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: hy-home-gw
  namespace: hy-home
spec:
  selector:
    istio: ingressgateway
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        - hy-home.local
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: hy-home-backend-vs
  namespace: hy-home
spec:
  hosts:
    - hy-home.local
  gateways:
    - hy-home-gw
  http:
    - name: primary
      match:
        - uri:
            prefix: /api/
      route:
        - destination:
            host: hy-home-backend
            port:
              number: 8000
```

---

### 5-4. Airflow (Helm, PostgreSQL/MinIO 사용)

Airflow Helm chart:

```bash
helm repo add apache-airflow https://airflow.apache.org
helm repo update

helm install airflow apache-airflow/airflow \
  -n airflow \
  -f kube/airflow/values.yaml
```

`kube/airflow/values.yaml` 핵심:

```yaml
images:
  airflow:
    tag: "3.1.3"  # 2025 기준 stable
executor: CeleryExecutor

data:
  metadataSecretName: airflow-metadata
  existingSecretConnection: true

logs:
  persistence:
    enabled: false  # 로그는 MinIO로
  existingSecret: airflow-logs-s3

airflow:
  config:
    AIRFLOW__CORE__SQL_ALCHEMY_CONN: "postgresql+psycopg2://hy:***@postgres-primary:5432/airflow"
    AIRFLOW__CORE__FERNET_KEY: "use-secret"
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "s3://airflow-logs/"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "minio_conn"
```

> Airflow용 DB/MinIO 자격증명도 Secret으로 분리.

---

### 5-5. n8n (Helm, PostgreSQL/Redis/MinIO 연동)

n8n Helm chart는 community-charts 또는 n8n community repo에서 설치.

```bash
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update

helm install n8n community-charts/n8n \
  -n n8n \
  -f kube/n8n/values.yaml
```

`kube/n8n/values.yaml` 요약:

```yaml
image:
  tag: "1.118.1"

env:
  - name: DB_TYPE
    value: postgresdb
  - name: DB_POSTGRESDB_HOST
    value: postgres-primary
  - name: DB_POSTGRESDB_PORT
    value: "5432"
  - name: DB_POSTGRESDB_DATABASE
    value: "n8n"
  - name: DB_POSTGRESDB_USER
    valueFrom:
      secretKeyRef:
        name: n8n-db
        key: user
  - name: DB_POSTGRESDB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: n8n-db
        key: password
  - name: N8N_ENCRYPTION_KEY
    valueFrom:
      secretKeyRef:
        name: n8n-encryption
        key: key
  - name: N8N_DEFAULT_BINARY_DATA_MODE
    value: s3
  - name: N8N_S3_ENDPOINT
    value: "http://minio.infra.svc.cluster.local:9000"
  - name: N8N_S3_BUCKET_NAME
    value: "n8n-binary"
```

---

## 6. NetworkPolicy & PodSecurity & egress 제어

### 6-1. 기본 default deny + DNS 허용

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: hy-home
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
```

DNS 허용:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: hy-home
spec:
  podSelector: {}
  policyTypes: [Egress]
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
```

백엔드 → 외부 DB/Redis/Kafka 허용:

```yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: allow-backend-external
  namespace: hy-home
spec:
  podSelector:
    matchLabels:
      app: hy-home-backend
  policyTypes: [Egress]
  egress:
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0   # 필요 시 192.168.0.0/16 등으로 축소
      ports:
        - port: 5432
          protocol: TCP
        - port: 7000
          protocol: TCP
        - port: 9092
          protocol: TCP
```

---

## 7. CI/CD: GitHub Actions + Kustomize + Argo Image Updater

### 7-1. Backend/Frontend 빌드 파이프라인 (hy-home.service-1-Backend / hy-home.frontend)

핵심 아이디어:

1. 서비스 리포에서 Docker 이미지 빌드 → GHCR에 푸시.
2. `hy-home-infra` 리포는 **이미지 태그를 Kustomize의 `images` 섹션**으로 관리.
3. `sed` 대신 `kustomize edit set image` 사용, 또는 Argo Image Updater로 태그 자동 업데이트.

GitHub Actions 예시 (Backend):

```yaml
# .github/workflows/cd.yaml
name: backend-cd

on:
  push:
    branches: [main]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        run: |
          IMAGE=ghcr.io/${{ github.repository_owner }}/hy-home-backend
          TAG=${{ github.sha }}
          docker build -t $IMAGE:$TAG .
          docker push $IMAGE:$TAG

      - name: Update kustomize images in hy-home-infra
        uses: actions/checkout@v4
        with:
          repository: buenhyden/hy-home-infra
          token: ${{ secrets.INFRA_REPO_TOKEN }}
          path: infra

      - name: Set image via kustomize
        working-directory: infra/apps/backend/overlays/docker-desktop
        run: |
          kustomize edit set image ghcr.io/${{ github.repository_owner }}/hy-home-backend=$IMAGE:$TAG

      - name: Commit & push
        working-directory: infra
        run: |
          git config user.name "github-actions"
          git config user.email "actions@users.noreply.github.com"
          git commit -am "chore: update backend image to $TAG" || echo "No changes"
          git push
```

이렇게 하면 sed 없이 Kustomize만으로 이미지 태그를 관리.

### 7-2. Argo Image Updater 연동 (선택)

Argo Image Updater를 쓸 경우, Rollout에 annotation만 붙이면 됨:

```yaml
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: >
      backend=ghcr.io/buenhyden/hy-home-backend
    argocd-image-updater.argoproj.io/backend.update-strategy: semver
```

이 경우 CI 파이프라인은 “이미지 빌드/푸시”만 하고, YAML 수정은 Argo Image Updater가 담당.

---

## 8. 실사용 환경과 비교 + 추가 구성 추천

### 8-1. 실서비스와의 유사점

* **하이브리드 구조**
  * K8s에는 서비스/관측/메쉬/정책/GitOps.
  * Docker에는 **“매니지드가 될 법한 것들”** – DB, 캐시, 스트리밍, 검색, 오브젝트 스토리지.
* **관측 스택**: Grafana Alloy + Loki + Tempo + Prometheus는 현재 관측계에서 자주 쓰이는 조합과 상당히 유사.
* **GitOps**: Argo CD + Rollouts + Image Updater + Notifications로, MSA SaaS 팀에서 사용하는 전형적인 GitOps 패턴을 재현.
* **정책**: Kyverno + PSA + NetworkPolicy default deny는 EKS/GKE 등에서 “보안 템플릿”으로 자주 잡는 구성이랑 거의 동일.

### 8-2. 실서비스 대비 간략화/차이점

* PostgreSQL HA:
  * 여기선 primary+replica 방식으로 “개념적인 HA”를 구성했지만, 실제 프로덕션에선 Patroni/Cloud SQL/RDS Multi-AZ 같은 더 강력한 솔루션이 필요.
* Redis Cluster:

  * docker-compose 기반으로 3노드 클러스터에 가깝게 구성했지만, 운용 편의성 측면에선 Redis Enterprise/ElastiCache와 차이가 있음.
* Kafka:

  * KRaft 기반 3브로커 + Schema Registry/Connect/REST Proxy 구조로 매니지드와 매우 비슷하지만, 보안·멀티 AZ·모니터링은 필요 최소만 반영.
* OpenSearch:

  * 공식 Compose 예제와 유사한 dev 클러스터 구조. 실제론 Snapshot Repository, Index Lifecycle Management, Hot-Warm 티어 등이 추가됨.
