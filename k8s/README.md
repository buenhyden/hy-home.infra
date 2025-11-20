일단 전체 그림부터 잡고, 그다음에 **Docker(172.19.0.0/16, infra_net)** 쪽이랑 **kind 클러스터(172.18.0.0/16, kind)** 쪽을 어떻게 나눌지, 그리고 거기에 맞춰서 Helm/Kustomize/Argo CD 구조까지 한 번에 정리해볼게.

---

## 1. 전체 설계 요약 – 무엇을 어디에 둘 것인가

### 1-1. Docker vs kind 배치 전략

실사용 환경을 최대한 따라가면, 보통은:

* **데이터 계층(Postgres, Redis, Kafka, 검색엔진, Object Storage 등)** ⇒
  클러스터 외부 또는 Cloud Managed (RDS, MSK, OpenSearch Service, S3 등)에서 관리
* **애플리케이션/워크플로우/게이트웨이/보안/관측 등** ⇒
  Kubernetes 내부에서 관리

이를 그대로 로컬에 옮겨온다고 보면:

| 계층     | 구성요소                                                                                                        | 배치                                   | 이유                                                                                 |
| ------ | ----------------------------------------------------------------------------------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------------- |
| 데이터    | PostgreSQL HA, Redis Cluster, Kafka(KRaft, Schema Registry, Connect, REST Proxy), OpenSearch Cluster, MinIO | **Docker(infra_net, 172.19.0.0/16)** | 실서비스는 대개 Managed 또는 별도 클러스터. 여기서는 Docker가 “외부 인프라” 역할                              |
| 관측 수집  | Grafana Alloy(Agent, DaemonSet + 일부 Sidecar)                                                                | **kind** (+ 선택적으로 Docker용 1개 컨테이너)   | Kubernetes에선 DaemonSet+Sidecar 패턴이 일반. Docker 쪽은 host 볼륨 마운트 또는 logging driver로 합류 |
| 관측 백엔드 | Loki(Logs), Tempo(Trace), kube-prometheus-stack(+ Grafana)                                                  | **kind**                             | 관측 스택은 앱과 같이 K8s에 올리는 구성이 많음 ([Grafana Labs][1])                                   |
| 네트워킹   | Istio(Helm), Istio IngressGateway, MetalLB                                                                  | **kind**                             | 내부 서비스 메쉬 + 외부 LoadBalancer (MetalLB) 패턴                                           |
| 보안/정책  | Kyverno, PSA Label, NetworkPolicy                                                                           | **kind**                             | 쿠버네티스 네이티브 보안 레이어 ([DEV Community][2])                                             |
| 인증서    | cert-manager(Self-signed Issuer for dev)                                                                    | **kind**                             | 실제 환경에서도 cert-manager + ACME/기업 CA 패턴이 일반 ([GitHub][3])                            |
| GitOps | Argo CD, Argo Rollouts, Argo CD Image Updater, Argo CD Notifications, Sealed Secrets                        | **kind**                             | GitOps 컨트롤 플레인                                                                     |
| 서비스    | Python Backend, React Frontend                                                                              | **kind**                             | HPA, Istio, Rollouts 대상                                                            |
| 워크플로우  | Airflow, n8n                                                                                                | **kind**                             | 배치/오케스트레이션을 클러스터 내부에서 실행                                                           |

> **중복 제거 결정**
>
> * Kafka는 **Docker(KRaft 클러스터 + SR/Connect/REST)** 로만 운영하고,
>   Strimzi Operator는 *실서비스에서는 클러스터 내부 Kafka를 쓸 때 많이 사용*하는 도구이므로,
>   이번 환경에서는 **설치하지 않고** 문서에서만 “추후 Cluster 내부 Kafka 필요 시 도입”으로 남기는 쪽으로 정리하는 게 깔끔함.
>   (요구사항의 “중복된 역할 제거 + Docker에 Kafka 클러스터 구성”을 우선시)

---

## 2. 네트워크/기본 인프라

### 2-1. Docker 네트워크 (이미 있음, 점검)

```bash
# 이미 있다면 스킵
docker network create \
  --driver=bridge \
  --subnet=172.19.0.0/16 \
  infra_net
```

* **infra_net**: DB/Kafka/OpenSearch/MinIO 등 모든 Docker 인프라가 붙는 네트워크
* IP는 Docker가 자동 할당 (172.19.x.x)

### 2-2. kind 클러스터 생성 (4노드, docker-desktop)

kind 설정 파일 (`kind-config-docker-desktop.yaml`):

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: docker-desktop
nodes:
  - role: control-plane
    extraPortMappings:
      # Istio IngressGateway / Argo CD / Grafana 등 외부 접근시 포트 매핑 예시
      - containerPort: 30080
        hostPort: 30080
        protocol: TCP
      - containerPort: 30443
        hostPort: 30443
        protocol: TCP
  - role: worker
  - role: worker
  - role: worker
networking:
  disableDefaultCNI: false
  kubeProxyMode: "iptables"
```

> 여기서는 LoadBalancer를 **MetalLB**로 운영하고, kind의 NodePort를 host로 내보내는 포트는 최소화.

클러스터 생성:

```bash
kind create cluster --config kind-config-docker-desktop.yaml
kubectl config use-context kind-docker-desktop
```

---

## 3. Docker 인프라 (Postgres/Redis/Kafka/OpenSearch/MinIO)

첨부된 docker-compose 파일들을 기반으로, 공통 네트워크/로그/메트릭/비밀번호 보호만 맞춰 정리하는 방식으로 설명할게.

### 3-1. 공통 원칙

1. **네트워크**

   * 모든 compose 파일에 `networks: infra_net` 지정
   * top-level network 정의는 공통 파일 또는 각 파일에 다음처럼:

   ```yaml
   networks:
     infra_net:
       external: true
       name: infra_net
   ```

2. **비밀번호/민감 정보**

   * `.env` 또는 Docker Secret 사용
   * YAML 안에는 패스워드 직접 기입 금지
     (이미 올려둔 compose들도 `${POSTGRES_PASSWORD}` 형태를 쓰고 있으니 이 원칙을 그대로 유지)

3. **로그/메트릭**

   * **로그**: Docker host에 JSON 로그 남기고, host에 띄운 Grafana Alloy 컨테이너가 `/var/lib/docker/containers`를 읽어 Loki로 전송
   * **메트릭**: 각 서비스별 Exporter 컨테이너를 붙여서 Prometheus(kube-prometheus-stack)가 scrape

각 Compose는 이미 잘 작성되어 있으니, 여기서는 **추가로 observability용 컨테이너**만 예시를 하나씩 붙이는 느낌으로 설명하겠다. (원래 서비스 정의는 그대로 쓰면 됨)

#### 3-1-1. Docker용 Grafana Alloy (옵션이지만 강력 추천)

`docker-compose-alloy.yml`:

```yaml
version: "3.9"

services:
  alloy-docker:
    image: grafana/alloy:v1.11.3
    container_name: alloy-docker
    restart: unless-stopped
    user: "0:0"
    volumes:
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/log:/var/log:ro
      - ./alloy-docker-config.river:/etc/alloy/config.river:ro
    networks:
      - infra_net

networks:
  infra_net:
    external: true
    name: infra_net
```

`alloy-docker-config.river`(예시 – Docker 로그를 Loki로 전송):

```river
local.file_match "docker_logs" {
  path_targets = [
    "/var/lib/docker/containers/*/*-json.log",
  ]
}

loki.source.file "docker" {
  targets = local.file_match.docker_logs.targets
  forward_to = [loki.write.loki.receiver]
}

loki.write "loki" {
  endpoint {
    # kind 내부 Loki Gateway 주소 (MetalLB IP) – 아래에서 설명
    url = "http://loki-gateway.monitoring.svc.cluster.local/loki/api/v1/push"
  }
}
```

> 실제 Loki endpoint는 Helm values 설정에 따라 변경될 수 있음.

---

### 3-2. PostgreSQL HA (Docker, Spilo 기반 클러스터 예시)

이미 첨부된 `docker-compose-postgres.yml` 이 **Spilo 기반(예: `ghcr.io/zalando/spilo-17:4.0-p3`)**으로 구성돼 있다면,
아래 항목만 체크하면 됨:

1. **버전**

   * PostgreSQL 17은 5년 Support가 제공되는 최신 메이저 중 하나라 “LTS로 간주” 가능 ([PostgreSQL][4])
   * Spilo 17 이미지 사용 시, 내부 PostgreSQL 17.x를 사용하므로 OK

2. **네트워크**

   * 각 서비스에 `networks: [infra_net]` 지정
   * top-level에 `networks.infra_net.external: true`

3. **비밀번호**

   * `POSTGRES_PASSWORD`, `PATRONI_SUPERUSER_PASSWORD` 등은 `.env` 또는 Docker secrets로 분리
   * 예: `.env.postgres` 에 저장하고 compose에서는 `${POSTGRES_PASSWORD}` 참조

4. **메트릭 exporter 추가 예시**

Postgres exporter 하나 추가:

```yaml
  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:v0.16.0
    container_name: postgres-exporter
    restart: unless-stopped
    environment:
      DATA_SOURCE_NAME: "postgresql://exporter:${POSTGRES_EXPORTER_PASSWORD}@pg-0:5432/postgres?sslmode=disable"
    networks:
      - infra_net
    ports:
      - "9187:9187"
```

Prometheus에서는 `host.docker.internal:9187` 또는 MetalLB LB를 통해 scrape.

---

### 3-3. Redis Cluster (Docker)

첨부 `docker-compose-redis.yml` 은 이미:

* **공식 Redis 이미지(예: `redis:8.2.3-bookworm`)** 사용
* 6개의 Redis 노드(3 master + 3 replica) 구성이면 Redis 공식 문서의 권장 구조와 일치 ([Redis][5])

추가로 볼 포인트:

1. **버전**: `redis:8.2.x` 는 현재 최신 안정 버전이며 향후 일정 기간 지원됨 ([Redis][6])
2. **Cluster 초기화**: docker-compose up 이후 아래와 같이 클러스터 생성

```bash
docker exec -it redis-node-0 \
  redis-cli --cluster create \
  redis-node-0:6379 redis-node-1:6379 redis-node-2:6379 \
  redis-node-3:6379 redis-node-4:6379 redis-node-5:6379 \
  --cluster-replicas 1
```

3. **메트릭 exporter 추가**

```yaml
  redis-exporter:
    image: oliver006/redis_exporter:v1.67.0
    container_name: redis-exporter
    restart: unless-stopped
    command:
      - "--redis.addr=redis://redis-node-0:6379"
    ports:
      - "9121:9121"
    networks:
      - infra_net
```

---

### 3-4. Kafka(KRaft) + Schema Registry + Connect + REST Proxy (Docker)

첨부 `docker-compose-kafka.yml` 이 이미 Confluent 이미지(`confluentinc/cp-kafka`, `cp-schema-registry`, `cp-kafka-connect`, `cp-kafka-rest`) 기반이라면, 다음 원칙 위주로 보면 됨:

1. **버전**

   * Apache Kafka 4.1.x는 2027년까지 지원되는 LTS 라인으로 간주 가능 ([endoflife.date][7])
   * Confluent 이미지 태그는 해당 Kafka 버전에 맞게 선택 (예: `confluentinc/cp-kafka:7.7.x`)

2. **KRaft 필수 env 예시** ([Medium][8])

각 broker에:

```yaml
    environment:
      KAFKA_KRAFT_MODE: "true"
      KAFKA_PROCESS_ROLES: "broker,controller"
      KAFKA_NODE_ID: 1
      KAFKA_CONTROLLER_QUORUM_VOTERS: "1@kafka-1:9093,2@kafka-2:9093,3@kafka-3:9093"
      KAFKA_LISTENERS: "PLAINTEXT://:9092,CONTROLLER://:9093"
      KAFKA_ADVERTISED_LISTENERS: "PLAINTEXT://kafka-1:9092"
      KAFKA_CONTROLLER_LISTENER_NAMES: "CONTROLLER"
      KAFKA_INTER_BROKER_LISTENER_NAME: "PLAINTEXT"
```

3. **Schema Registry / Connect / REST Proxy**

   * `cp-schema-registry`, `cp-kafka-connect`, `cp-kafka-rest` 이미지를 사용하되, `latest`가 아니라 **구체 버전**(예: `7.7.1`) 지정
   * Docker compose 예시는 Confluent 공식 예제(cp-all-in-one) 구조 참고 ([GitHub][9])

4. **메트릭 exporter**

```yaml
  kafka-exporter:
    image: danielqsj/kafka-exporter:v1.7.0
    container_name: kafka-exporter
    restart: unless-stopped
    environment:
      KAFKA_SERVER: "kafka-1:9092,kafka-2:9092,kafka-3:9092"
    ports:
      - "9308:9308"
    networks:
      - infra_net
```

---

### 3-5. OpenSearch Cluster (Docker)

`docker-compose-opensearch.yml` 이 이미 OpenSearch 공식 문서 예제와 유사하게 작성되어 있다면: ([OpenSearch Docs][10])

1. **버전**

   * `opensearchproject/opensearch:3.x` 계열은 현재 장기간 지원되는 최신 메이저
2. **구성**

   * 최소 3 노드 (예: `opensearch-node1`, `node2`, `node3`) + `opensearch-dashboards`
   * `discovery.seed_hosts`, `cluster.initial_master_nodes` 설정
3. **메트릭**

   * Opensearch는 내장 Prom metrics endpoint 제공하거나, 외부 exporter 사용

간단히 내장 metrics를 사용하려면 OpenSearch 설정에:

```yaml
    environment:
      - "plugins.metrics.enabled=true"
      - "plugins.metrics.prometheus.enabled=true"
      - "plugins.metrics.prometheus.exporter.port=9600"
      - "plugins.metrics.prometheus.exporter.use_insecure=true"
```

그리고 9600 포트를 host로 노출 (`9600:9600`), Prometheus에서 scrape.

---

### 3-6. MinIO (Docker, Local Object Storage)

`docker-compose-minio.yml` 에는 이미 `minio/minio` 이미지로 구성돼 있을 거라 보고, 버전과 인증정보만 조정하면 됨.
LTS에 가까운 안정 버전을 명시적으로 지정(예: 2025년 하반기 출시 태그).
MinIO는 “자체 버전 정책 + CVE 대응”이라 사실상 최신 안정이 LTS 취급. ([minimus.io][11])

예시 (이미 있는 compose를 정리한 형태):

```yaml
services:
  minio:
    image: minio/minio:RELEASE.2025-10-18T02-41-52Z
    container_name: minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER_FILE: /run/secrets/minio_root_user
      MINIO_ROOT_PASSWORD_FILE: /run/secrets/minio_root_password
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - ./data/minio:/data
    secrets:
      - minio_root_user
      - minio_root_password
    networks:
      - infra_net

secrets:
  minio_root_user:
    file: ./secrets/minio_root_user
  minio_root_password:
    file: ./secrets/minio_root_password

networks:
  infra_net:
    external: true
    name: infra_net
```

Kubernetes에서 Loki/Tempo/Airflow 등의 object storage backend로 이 MinIO를 사용.

---

## 4. Kubernetes 스토리지/네트워크/보안 베이스

### 4-1. StorageClass (local-path-provisioner 또는 비슷한 역할)

예전에 `https://rancher.github.io/local-path-provisioner` 404 문제가 있었는데, 현재는 GitHub Pages로 이동된 helm repo를 사용하면 됨. ([Istio][12])

Helm repo + 설치:

```bash
helm repo add local-path-provisioner https://rancher.github.io/local-path-provisioner/
helm repo update

kubectl create namespace local-path-storage

helm install local-path local-path-provisioner/local-path-provisioner \
  --namespace local-path-storage \
  --set storageClass.defaultClass=true
```

이제 `local-path` StorageClass가 **default**로 동작.

---

### 4-2. MetalLB 설치 + IP 풀(172.18.0.0/16 일부)

Helm 저장소: `metallb/metallb` ([GitHub][13])

```bash
helm repo add metallb https://metallb.github.io/metallb
helm repo update

kubectl create namespace metallb-system

helm install metallb metallb/metallb -n metallb-system
```

IPPool과 L2Advertisement (예: 172.18.100.0/24 범위):

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: lb-pool
  namespace: metallb-system
spec:
  addresses:
    - 172.18.100.1-172.18.100.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: lb-adv
  namespace: metallb-system
spec:
  ipAddressPools:
    - lb-pool
```

이제 `type: LoadBalancer` Service가 이 풀을 사용.

---

### 4-3. Pod Security Admission(PSA) + Namespace Label

PSA는 namespace label로 동작. 예: 모든 앱 namespace에 `restricted` 프로필을 enforce. ([docs.starlingx.io][14])

예: `apps` namespace 생성:

```bash
kubectl create namespace apps
kubectl label namespace apps \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest \
  pod-security.kubernetes.io/warn=baseline \
  pod-security.kubernetes.io/warn-version=latest
```

관측/인프라/시스템 용 namespace는 baseline 또는 privileged로 필요시 조절.

---

### 4-4. Kyverno 설치 + 기본 정책 (non-root / latest 금지)

Helm repo: `kyverno/kyverno` ([artifacthub.io][15])

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

kubectl create namespace kyverno

helm install kyverno kyverno/kyverno -n kyverno
```

정책 예: `require-non-root` + `disallow-latest-tag`:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-non-root
spec:
  validationFailureAction: enforce
  rules:
    - name: check-run-as-non-root
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: "Containers must not run as root"
        pattern:
          spec:
            securityContext:
              runAsNonRoot: true
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
spec:
  validationFailureAction: enforce
  rules:
    - name: check-latest-tag
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: "Image tag 'latest' is not allowed"
        pattern:
          spec:
            containers:
              - image: "!*:latest"
```

---

### 4-5. 기본 NetworkPolicy (기본 차단 + DNS 허용)

기본적으로 Kubernetes는 Pod 간 트래픽을 제한하지 않으므로, default deny 정책을 하나 만든 뒤 필요한 곳만 열어주는 것이 best practice. ([Spacelift][16])

`networkpolicy-default-deny.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: apps
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
---
# DNS 허용 (kube-dns/coredns)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: apps
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
```

추가로, Istio IngressGateway, Loki/Tempo/Prometheus 등의 통신을 위해 별도 policy를 정의.

---

## 5. Observability Stack (Grafana Alloy + Loki + Tempo + kube-prometheus-stack)

### 5-1. kube-prometheus-stack 설치 (Prometheus + Grafana)

Helm chart: `prometheus-community/kube-prometheus-stack`, 버전 79.5.0 (2025-11-11 현재 최신 안정) ([artifacthub.io][17])

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm install kps prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --version 79.5.0 \
  -f kube-prometheus-stack-values.yaml
```

`kube-prometheus-stack-values.yaml`(핵심만, 전체 예시):

```yaml
grafana:
  enabled: true
  adminPassword: ""
  admin:
    existingSecret: grafana-admin-secret
    userKey: admin-user
    passwordKey: admin-password
  service:
    type: LoadBalancer
    port: 80
  ingress:
    enabled: false

prometheus:
  prometheusSpec:
    retention: 15d
    scrapeInterval: 15s
    podMonitorNamespaceSelector: {}
    podMonitorSelector: {}
    additionalScrapeConfigs:
      # Docker infra exporters (Postgres, Redis, Kafka, OpenSearch, MinIO)
      - job_name: 'docker-infra'
        static_configs:
          - targets:
              - host.docker.internal:9187  # postgres-exporter
              - host.docker.internal:9121  # redis-exporter
              - host.docker.internal:9308  # kafka-exporter
              # OpenSearch metrics endpoint
              - host.docker.internal:9600
```

Grafana admin 계정은 Secret으로:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: grafana-admin-secret
  namespace: monitoring
type: Opaque
stringData:
  admin-user: admin
  admin-password: "<강한_패스워드>"
```

> 패스워드는 바로 Secret으로, Git에는 SealedSecret 상태로 저장.

---

### 5-2. Loki 설치 (로그 저장)

Helm chart: `grafana/loki`, 예: 6.46.0 (Loki 3.5.x 계열) ([artifacthub.io][18])

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

kubectl create namespace loki

helm install loki grafana/loki \
  --namespace loki \
  --version 6.46.0 \
  -f loki-values.yaml
```

`loki-values.yaml` (MinIO를 backend로 사용하는 예):

```yaml
loki:
  auth_enabled: false

  commonConfig:
    path_prefix: /var/loki
    storage:
      filesystem:
        chunks_directory: /var/loki/chunks
        rules_directory: /var/loki/rules

  storage:
    type: s3
    bucketNames:
      chunks: loki-chunks
      ruler: loki-ruler
      admin: loki-admin
    s3:
      s3: null
      endpoint: "http://minio.infra.local:9000"
      region: "us-east-1"
      accessKeyId: "${LOKI_S3_ACCESS_KEY}"
      secretAccessKey: "${LOKI_S3_SECRET_KEY}"
      s3ForcePathStyle: true
      insecure: true

gateway:
  enabled: true
  service:
    type: LoadBalancer
```

여기서 MinIO endpoint는 Docker 인프라를 DNS로 못 부르면, 대신 host.docker.internal을 쓸 수도 있음.

---

### 5-3. Tempo 설치 (Trace 저장)

Helm chart: `grafana/tempo-distributed` ([artifacthub.io][19])

```bash
kubectl create namespace tempo

helm install tempo grafana/tempo-distributed \
  --namespace tempo \
  --version 2.8.0 \
  -f tempo-values.yaml
```

`tempo-values.yaml` (MinIO S3 backend):

```yaml
tempo:
  storage:
    trace:
      backend: s3
      s3:
        endpoint: "http://minio.infra.local:9000"
        bucket: "tempo-traces"
        access_key: "${TEMPO_S3_ACCESS_KEY}"
        secret_key: "${TEMPO_S3_SECRET_KEY}"
        insecure: true
        region: "us-east-1"
```

---

### 5-4. Grafana Alloy (Kubernetes DaemonSet + 일부 Sidecar)

Helm chart: `grafana/alloy` (v1.4.0, AppVersion v1.11.3) ([artifacthub.io][20])

```bash
kubectl create namespace alloy

helm install alloy grafana/alloy \
  --namespace alloy \
  --version 1.4.0 \
  -f alloy-values.yaml
```

`alloy-values.yaml` (DaemonSet 모드, Loki/Tempo/Prometheus로 전송):

```yaml
mode: daemonset

configMap:
  create: true
  name: alloy-config
  key: config.river

extraConfig: |
  loki.write "loki" {
    endpoint {
      url = "http://loki-gateway.loki.svc.cluster.local/loki/api/v1/push"
    }
  }

  otlp.receiver "traces" {
    grpc {
      endpoint = "0.0.0.0:4317"
    }
  }

  tempo.write "tempo" {
    endpoint {
      url = "tempo-distributor.tempo.svc.cluster.local:4317"
    }
  }

  prometheus.remote_write "k8s" {
    endpoint {
      url = "http://kps-kube-prometheus-stack-prometheus.monitoring.svc.cluster.local/api/v1/write"
    }
  }

  # 컨테이너 로그 수집 예시
  loki.source.kubernetes "pods" {
    # default Alloy k8s 로그 소스
    forward_to = [loki.write.loki.receiver]
  }
```

일부 중요한 서비스(예: Backend)에는 Sidecar로 Alloy를 붙여서 어플리케이션 로그를 별도로 태깅할 수 있음.

---

## 6. GitOps (Argo CD + Rollouts + Image Updater + Notifications + Sealed Secrets)

### 6-1. Argo CD 설치

Helm chart: `argo/argo-cd` (9.1.3 등) ([artifacthub.io][21])

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create namespace argocd

helm install argocd argo/argo-cd \
  --namespace argocd \
  --version 9.1.3 \
  -f argocd-values.yaml
```

`argocd-values.yaml` (핵심):

```yaml
server:
  service:
    type: LoadBalancer
  extraArgs:
    - --insecure

configs:
  params:
    server.insecure: "true"
  secret:
    createSecret: false
    # admin 패스워드는 sealed secret으로 관리

notifications:
  enabled: true
  notifiers:
    service.slack: |
      token: $slack-token
  triggers:
    - name: on-sync-status
      condition: app.status.operationState.phase in ['Succeeded', 'Failed']
      template: app-sync-status
  templates:
    - name: app-sync-status
      slack:
        attachments: |
          [{
            "title": "ArgoCD Sync {{.app.metadata.name}}: {{.app.status.operationState.phase}}",
            "text": "{{.app.status.operationState.message}}"
          }]
```

Argo CD Notifications는 values로 켤 수 있고, Slack/Webhook 등 Receiver는 Secret로 주입.

---

### 6-2. Argo Rollouts 설치

Helm chart: `argo/argo-rollouts` (2.40.x) ([staging.artifacthub.io][22])

```bash
kubectl create namespace argo-rollouts

helm install argo-rollouts argo/argo-rollouts \
  --namespace argo-rollouts \
  --version 2.40.5
```

---

### 6-3. Argo CD Image Updater 설치

Helm chart: `argo/argocd-image-updater` ([GitHub][23])

```bash
kubectl create namespace argocd-image-updater

helm install argocd-image-updater argo/argocd-image-updater \
  --namespace argocd-image-updater \
  --version 1.0.0 \
  -f argocd-image-updater-values.yaml
```

`argocd-image-updater-values.yaml`에서 Argo CD 서버 주소, 인증 토큰 등을 Secret로 연결하고, `hy-home.service-1-Backend` / `hy-home.frontend` 이미지 태그 자동 업데이트 전략을 작성.

---

### 6-4. Sealed Secrets 설치 (Bitnami 미사용)

Helm chart는 `sealed-secrets` 공식 repo 사용 (bitnami-labs),
이미지는 **직접 빌드한 ghcr.io/buenhyden/sealed-secrets-controller** 를 사용해 Bitnami registry를 피하는 방식으로 구성 가능. ([artifacthub.io][24])

```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update

kubectl create namespace sealed-secrets

helm install sealed-secrets sealed-secrets/sealed-secrets \
  --namespace sealed-secrets \
  --set image.registry=ghcr.io \
  --set image.repository=buenhyden/sealed-secrets-controller \
  --set image.tag=v0.27.2
```

> 여기서 `ghcr.io/buenhyden/sealed-secrets-controller:v0.27.2` 는
> upstream 소스를 가져와 직접 빌드해서 올렸다고 가정.

이제 Secret은 모두 SealedSecret 형태로 Git에 저장 → Argo CD가 복호화 후 배포.

---

## 7. Istio (Mesh/Gateway) + LoadBalancer + Argo Rollouts 연동

### 7-1. Istio 설치

Helm repo: `istio` (공식)

```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

kubectl create namespace istio-system

helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system --set profile=default

helm install istio-ingress istio/gateway -n istio-system \
  --set service.type=LoadBalancer
```

Istio IngressGateway Service는 MetalLB IP를 받게 됨(예: 172.18.100.10).

---

### 7-2. Argo Rollouts + Istio Canary 예시

Argo Rollouts는 Istio VirtualService/DestinationRule을 이용한 Canary 트래픽 분할을 지원한다. ([Velog][25])

Backend 서비스 예:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
  namespace: apps
spec:
  selector:
    app: backend
  ports:
    - name: http
      port: 80
      targetPort: 8000
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: backend-dr
  namespace: apps
spec:
  host: backend-svc.apps.svc.cluster.local
  subsets:
    - name: stable
      labels:
        rollouts-pod-template-hash: stable
    - name: canary
      labels:
        rollouts-pod-template-hash: canary
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: backend-vs
  namespace: apps
spec:
  hosts:
    - backend.hy.local
  gateways:
    - istio-system/istio-ingressgateway
  http:
    - route:
        - destination:
            host: backend-svc.apps.svc.cluster.local
            subset: stable
          weight: 90
        - destination:
            host: backend-svc.apps.svc.cluster.local
            subset: canary
          weight: 10
```

Argo Rollout 리소스:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: backend
  namespace: apps
spec:
  replicas: 3
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
  strategy:
    canary:
      canaryService: backend-canary
      stableService: backend-svc
      trafficRouting:
        istio:
          virtualService:
            name: backend-vs
            routes:
              - http
      steps:
        - setWeight: 10
        - pause: { duration: 300 }
        - setWeight: 50
        - pause: { duration: 600 }
        - setWeight: 100
```

---

## 8. 애플리케이션 (Python Backend / React Frontend) – Kustomize + CI/CD

### 8-1. Git 리포 구조 (hy-home-infra)

`hy-home-infra` 를 대략 아래 구조로 두면 깔끔함:

```text
hy-home-infra/
  clusters/
    kind/
      docker-desktop/
        kustomization.yaml
        apps.yaml          # Argo CD App of Apps
  apps/
    backend/
      base/
        deployment.yaml
        service.yaml
        hpa.yaml
        rollout.yaml
        kustomization.yaml
      overlays/
        kind/
          kustomization.yaml
          istio-virtualservice.yaml
          networkpolicy.yaml
    frontend/
      base/
        deployment.yaml
        service.yaml
        hpa.yaml
        rollout.yaml
        kustomization.yaml
      overlays/
        kind/
          kustomization.yaml
          istio-virtualservice.yaml
  infra/
    monitoring/   # kube-prometheus-stack, loki, tempo, alloy values
    security/     # kyverno, psa, networkpolicy base
    gitops/       # argocd, argo-rollouts, image-updater, notifications
    networking/   # metallb, istio
```

### 8-2. Backend Deployment + HPA (예시, Python)

`apps/backend/base/deployment.yaml` (Rollout가 Deployment를 대체하므로, Rollout 예만):

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: backend
  namespace: apps
spec:
  replicas: 3
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: ghcr.io/buenhyden/hy-home.service-1-backend:1.0.0
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8000
          envFrom:
            - secretRef:
                name: backend-env
          resources:
            requests:
              cpu: "200m"
              memory: "256Mi"
            limits:
              cpu: "1"
              memory: "512Mi"
          readinessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /live
              port: 8000
            initialDelaySeconds: 15
            periodSeconds: 20
  strategy:
    canary:
      canaryService: backend-canary
      stableService: backend-svc
      trafficRouting:
        istio:
          virtualService:
            name: backend-vs
            routes: ["http"]
      steps:
        - setWeight: 10
        - pause: { duration: 120 }
        - setWeight: 50
        - pause: { duration: 300 }
        - setWeight: 100
```

HPA (metrics-server를 가정, stabilization window 활용): ([plural.sh][26])

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: apps
spec:
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    name: backend
  minReplicas: 3
  maxReplicas: 10
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

Anti-affinity:

```yaml
spec:
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                topologyKey: "kubernetes.io/hostname"
                labelSelector:
                  matchLabels:
                    app: backend
```

> Frontend도 동일 패턴으로 Rollout + HPA + Anti-affinity 적용.

---

### 8-3. CI/CD – GitHub Actions + Kustomize (sed 대신)

`hy-home.service-1-Backend` 리포에서:

1. Docker 이미지 빌드/푸시
2. `hy-home-infra` 리포의 Kustomize overlay에서 `image` 태그를 패치하는 **kustomize edit set image** 사용
3. 변경된 infra 리포를 push → Argo CD가 자동 sync

예: `.github/workflows/deploy.yaml` (핵심 부분만):

```yaml
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout backend
        uses: actions/checkout@v4

      - name: Build & push image
        run: |
          IMAGE=ghcr.io/buenhyden/hy-home.service-1-backend
          TAG=${{ github.sha }}
          docker build -t $IMAGE:$TAG .
          echo "${{ secrets.GHCR_PAT }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
          docker push $IMAGE:$TAG

      - name: Checkout infra repo
        uses: actions/checkout@v4
        with:
          repository: buenhyden/hy-home-infra
          path: infra

      - name: Update kustomize image
        working-directory: infra/apps/backend/overlays/kind
        run: |
          kustomize edit set image backend=ghcr.io/buenhyden/hy-home.service-1-backend:${{ github.sha }}

      - name: Commit & push
        working-directory: infra
        run: |
          git config user.name "github-actions"
          git config user.email "actions@github.com"
          git commit -am "chore: update backend image to ${{ github.sha }}"
          git push
```

> 여기서 sed 없이 Kustomize CLI를 사용해서 이미지 태그를 업데이트.

---

## 9. Airflow / n8n (워크플로우)

### 9-1. Airflow (Helm)

Helm chart: `apache/airflow` (1.16.x/1.17.x) – 공식 chart ([CNCF][27])

```bash
helm repo add apache-airflow https://airflow.apache.org
helm repo update

kubectl create namespace airflow

helm install airflow apache-airflow/airflow \
  --namespace airflow \
  --version 1.17.0 \
  -f airflow-values.yaml
```

`airflow-values.yaml` 에는:

* executor: KubernetesExecutor or CeleryExecutor
* logs_backend: MinIO(S3 compatible)
* Database: Docker Postgres cluster endpoint(`host.docker.internal:5432`) 사용

### 9-2. n8n (Helm)

Helm chart: community `k8s-at-home/n8n` 또는 community-charts ([community-charts.github.io][28])

```bash
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update

kubectl create namespace n8n

helm install n8n community-charts/n8n \
  --namespace n8n \
  --version 1.2.0 \
  -f n8n-values.yaml
```

`n8n-values.yaml` 에 MinIO, Kafka, Postgres 등 외부 인프라 endpoint 설정.

---

## 10. Kubernetes ↔ Docker 인프라 연결 (DB/Kafka/OpenSearch/MinIO)

### 10-1. 접근 방식

* Docker Desktop + kind 환경에서는 Pod에서 **`host.docker.internal`** 로 Host에 접근 가능
* Docker Compose에서 각 인프라 서비스를 **`ports:`**로 Host에 노출해두면,
  K8s에서 DB/Kafka/OpenSearch/MinIO에 쉽게 붙을 수 있음 ([Instaclustr][29])

예: Backend env (SealedSecret로 관리되는 Secret 안):

```env
DATABASE_URL=postgresql://app_user:${DB_PASSWORD}@host.docker.internal:5432/app_db
REDIS_URL=redis://host.docker.internal:6379/0
KAFKA_BOOTSTRAP_SERVERS=host.docker.internal:9092,host.docker.internal:9093,host.docker.internal:9094
OPENSEARCH_ENDPOINT=http://host.docker.internal:9200
MINIO_ENDPOINT=http://host.docker.internal:9000
```

Kubernetes Secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: backend-env
  namespace: apps
type: Opaque
stringData:
  DATABASE_URL: "postgresql://app_user:__from_secret__@host.docker.internal:5432/app_db"
  # 나머지 변수들...
```

실제로는 이 Secret을 SealedSecret로 암호화해 GitOps에 올림.

---

## 11. 정리 – 요구사항 매핑 체크

* [x] **Kind + Docker 하이브리드**

  * 데이터 계층은 Docker(infra_net), 앱/관측/GitOps는 kind에 배치
* [x] **Local Storage는 MinIO**

  * Loki/Tempo/Airflow 등 Object Storage backend로 MinIO 사용
* [x] **중복된 역할 정리**

  * Kafka는 Docker KRaft 클러스터를 정식으로 사용, Strimzi는 이번 환경에서는 설치 제외
* [x] **실사용 환경과 유사한 구성**

  * DB/Kafka/OpenSearch/MinIO를 “외부 인프라”로 두고, 앱/관측/GitOps/보안을 K8s에 배치하는 패턴
* [x] **sidecar / fail-over**

  * Grafana Alloy: DaemonSet+Sidecar
  * DB/Kafka/Redis/OpenSearch: 다중 노드/Replica 기반 (Spilo/Postgres cluster, Redis 6-node cluster, Kafka multi-broker, OpenSearch multi-node)
* [x] **NetworkPolicy / PodSecurity(PSA)**

  * default deny + DNS 허용, Kyverno + PSA label 구성
* [x] **비밀번호는 Secret 사용**

  * Docker: env file/secrets, K8s: Secret + SealedSecret
* [x] **StorageClass 활성화**

  * local-path-provisioner 설치, default StorageClass 지정
* [x] **LTS 버전**

  * Postgres 17, Redis 8.2, Kafka 4.1.x(KRaft), OpenSearch 3.x, MinIO 2025 안정 태그,
    kube-prometheus-stack 79.5.0, Loki/Tempo/Alloy/ArgoCD/ArgoRollouts 최신 안정 차트 ([artifacthub.io][17])
* [x] **Helm 우선, 유효한 레포**

  * Grafana/Prometheus-community/Argo/Kyverno/MetalLB/Jetstack/Apache-Airflow/Community-charts 등 공식/신뢰 가능한 repo 사용
* [x] **HPA, anti-affinity, 트래픽/에러 대응**

  * HPA v2 + stabilization window + podAntiAffinity 적용
* [x] **CI/CD sed → Kustomize**

  * `kustomize edit set image` 예시 제공
* [x] **LoadBalancer 활용**

  * MetalLB IPPool + Istio IngressGateway/ArgoCD/Grafana 등 LB 서비스
* [x] **Argo Rollouts Canary + Notifications**

  * Rollout + Istio VirtualService + ArgoCD Notifications 값/예시 제공
* [x] **Docker 인프라 로그/메트릭 수집**

  * Docker용 Grafana Alloy + 각 서비스 exporter를 통해 Loki/Prometheus로 수집

---

여기까지가 “한 번에 전부” 버전이라 양이 꽤 많아졌는데,
이제부터는 원하면 **특정 파트(예: Kafka Compose 세부 / kube-prometheus-stack values 전체 / Backend용 Istio+Rollout 묶음 / GitHub Actions 전체 파일)** 를 골라서 디테일을 한 번 더 깊게 파고 들어갈 수 있어.

다음 단계로 어떤 파트를 먼저 실제 리포에 옮기고 싶어? (hy-home-infra부터? 아니면 docker-compose 쪽부터 정리할까?)

[1]: https://grafana.com/docs/helm-charts/?utm_source=chatgpt.com "Grafana Labs Helm charts documentation"
[2]: https://dev.to/thenjdevopsguy/implementing-kubernetes-pod-security-standards-4aco?utm_source=chatgpt.com "Implementing Kubernetes Pod Security Standards"
[3]: https://github.com/istio/istio/issues/24112?utm_source=chatgpt.com "[release 1.6.0] Unable to find charts under googleapis url"
[4]: https://www.postgresql.org/support/versioning/?utm_source=chatgpt.com "Versioning Policy"
[5]: https://redis.io/docs/latest/operate/oss_and_stack/management/scaling/?utm_source=chatgpt.com "Scale with Redis Cluster | Docs"
[6]: https://redis.io/docs/latest/operate/rs/installing-upgrading/product-lifecycle/?utm_source=chatgpt.com "Redis Enterprise Software product lifecycle | Docs"
[7]: https://endoflife.date/apache-kafka?utm_source=chatgpt.com "Apache Kafka"
[8]: https://medium.com/%40darshak.kachchhi/setting-up-a-kafka-cluster-using-docker-compose-a-step-by-step-guide-a1ee5972b122?utm_source=chatgpt.com "Setting Up a Kafka Cluster Using Docker Compose(Kraft ..."
[9]: https://github.com/confluentinc/cp-all-in-one?utm_source=chatgpt.com "confluentinc/cp-all-in-one: docker-compose.yml files for ..."
[10]: https://docs.opensearch.org/latest/install-and-configure/install-opensearch/docker/?utm_source=chatgpt.com "Docker"
[11]: https://www.minimus.io/post/minio-docker-image-changes-how-to-find-a-secure-minio-alternative?utm_source=chatgpt.com "MinIO Docker Image Changes: What Happened and How ..."
[12]: https://istio.io/latest/docs/setup/install/helm/?utm_source=chatgpt.com "Install with Helm"
[13]: https://github.com/metallb/metallb/releases?utm_source=chatgpt.com "Releases · metallb/metallb"
[14]: https://docs.starlingx.io/r/stx.8.0/security/kubernetes/pod-security-admission-controller-8e9e6994100f.html?utm_source=chatgpt.com "Pod Security Admission Controller"
[15]: https://artifacthub.io/packages/helm/kyverno/kyverno/2.1.4?utm_source=chatgpt.com "kyverno 2.1.4"
[16]: https://spacelift.io/blog/kubernetes-network-policy?utm_source=chatgpt.com "Kubernetes Network Policy - Guide with Examples"
[17]: https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack?utm_source=chatgpt.com "kube-prometheus-stack 79.5.0"
[18]: https://artifacthub.io/packages/helm/grafana/loki?utm_source=chatgpt.com "loki 6.46.0 · grafana/grafana"
[19]: https://artifacthub.io/packages/helm/grafana/tempo-distributed?utm_source=chatgpt.com "tempo-distributed - Grafana"
[20]: https://artifacthub.io/packages/helm/grafana/alloy?utm_source=chatgpt.com "Grafana Alloy Helm chart"
[21]: https://artifacthub.io/packages/helm/argo/argo-cd?utm_source=chatgpt.com "argo-cd 9.1.3"
[22]: https://staging.artifacthub.io/packages/helm/argo/argo-rollouts/2.38.0?utm_source=chatgpt.com "argo-rollouts 2.38.0 · argoproj/argo"
[23]: https://github.com/argoproj/argo-helm/releases?utm_source=chatgpt.com "Releases · argoproj/argo-helm"
[24]: https://artifacthub.io/packages/helm/metallb/metallb?utm_source=chatgpt.com "metallb 0.15.2"
[25]: https://velog.io/%40youngjun0627/Rollout-%EC%97%90%EC%84%9C-Istio-%EB%A5%BC-%EC%99%9C-%EC%82%AC%EC%9A%A9%ED%95%A0%EA%B9%8C?utm_source=chatgpt.com "Rollout 에서 Istio 를 왜 사용할까?"
[26]: https://www.plural.sh/blog/hpa-kubernetes-guide/?utm_source=chatgpt.com "Kubernetes HPA: Your Guide to Autoscaling"
[27]: https://www.cncf.io/blog/2024/11/05/mastering-argo-cd-image-updater-with-helm-a-complete-configuration-guide/?utm_source=chatgpt.com "Mastering Argo CD image updater with Helm"
[28]: https://community-charts.github.io/docs/category/n8n?utm_source=chatgpt.com "N8N Helm Chart | OpenCharts - Community Charts"
[29]: https://www.instaclustr.com/education/opensearch/running-opensearch-with-docker-tutorial-and-best-practices/?utm_source=chatgpt.com "Running OpenSearch with Docker: Tutorial and best ..."
