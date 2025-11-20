# hy-home-infra

데이터 계층(Postgres, Redis, Kafka, 검색엔진, Object Storage 등) ⇒ 클러스터 외부 또는 Cloud Managed (RDS, MSK, OpenSearch Service, S3 등)에서 관리
애플리케이션/워크플로우/게이트웨이/보안/관측 등 ⇒ Kubernetes 내부에서 관리
| 계층     | 구성요소                                                                                                        | 배치                                   | 이유                                                                                 |
| ------ | ----------------------------------------------------------------------------------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------------- |
| 데이터    | PostgreSQL HA, Redis Cluster, Kafka(KRaft, Schema Registry, Connect, REST Proxy), OpenSearch Cluster, MinIO | **Docker(infra_net, 172.19.0.0/16)** | 실서비스는 대개 Managed 또는 별도 클러스터. 여기서는 Docker가 “외부 인프라” 역할                              |
| 관측 수집  | Grafana Alloy(Agent, DaemonSet + 일부 Sidecar)                                                                | **kind** (+ 선택적으로 Docker용 1개 컨테이너)   | Kubernetes에선 DaemonSet+Sidecar 패턴이 일반. Docker 쪽은 host 볼륨 마운트 또는 logging driver로 합류 |
| 관측 백엔드 | Loki(Logs), Tempo(Trace), kube-prometheus-stack(+ Grafana)                                                  | **kind**                             | 관측 스택은 앱과 같이 K8s에 올리는 구성이 많음                                 |
| 네트워킹   | Istio(Helm), Istio IngressGateway, MetalLB                                                                  | **kind**                             | 내부 서비스 메쉬 + 외부 LoadBalancer (MetalLB) 패턴                                           |
| 보안/정책  | Kyverno, PSA Label, NetworkPolicy                                                                           | **kind**                             | 쿠버네티스 네이티브 보안 레이어                                             |
| 인증서    | cert-manager(Self-signed Issuer for dev)                                                                    | **kind**                             | 실제 환경에서도 cert-manager + ACME/기업 CA 패턴이 일반                           |
| GitOps | Argo CD, Argo Rollouts, Argo CD Image Updater, Argo CD Notifications, Sealed Secrets                        | **kind**                             | GitOps 컨트롤 플레인                                                                     |
| 서비스    | Python Backend, React Frontend                                                                              | **kind**                             | HPA, Istio, Rollouts 대상                                                            |
| 워크플로우  | Airflow, n8n                                                                                                | **kind**                             | 배치/오케스트레이션을 클러스터 내부에서 실행                                                           |

## IP/네트워크 전제

- Docker Desktop의 kind 네트워크: 172.18.0.0/16 (이미 확인한 정보)
- MetalLB IP 풀: 172.18.255.200-172.18.255.250 정도를 사용 (kind 노드 IP와 겹치지 않게 상단 일부만 사용)
- Loki/Tempo/Prometheus Ingest는 LoadBalancer(Service) + MetalLB IP를 사용해 Docker 쪽 Alloy가 접근

## 리토지토리 기본 구조

```text
hy-home-infra/
  Docker/
    docker-compose.yml
    .env                # Docker용 공통 환경 변수(민감 정보는 별도 파일 or Docker secrets)    
    configs/
      elasticsearch/
      postgres/
      redis/      
    Infra/
      airflow/
      alloy/
      cadvisor/
      elasticsearch/
      harbor/
      influxdb/
      kafka/
      keycloak/
      minio/
      mongodb/
      n8n/
      opensearch/
      postgresql/      
      redis/
      wikijs/
    Projects/
      Django/
      ExpressJS/
      FastAPI/
      Gradle/
      Maven/
      NestJS/
      NextJS/
      ReactJS/
    secrets/
      postgres_password.txt
      redis_password.txt      
      minio_root_password.txt
      minio_root_user.txt
  Kubernetes/
    base/
      namespaces.yaml
      storage/
        local-path-storage.yaml    # StorageClass
      networking/
        metallb-values.yaml
        istio-values.yaml
      monitoring/
        kube-prometheus-stack-values.yaml
        loki-values.yaml
        tempo-values.yaml
        alloy-daemonset.yaml
      security/
        kyverno-values.yaml
        kyverno-policies.yaml
        podsecurity-namespaces.yaml
        networkpolicy-default-deny.yaml
        networkpolicy-allow-dns.yaml
      gitops/
        argocd-values.yaml
        argocd-app-of-apps.yaml
        argo-rollouts-values.yaml
        sealed-secrets-install.yaml
    overlays/
      kind/
        kustomization.yaml
        # 필요시 patch들
  apps/
    backend/
      kustomization.yaml
      rollout.yaml
      service.yaml
      virtualservice.yaml
      destinationrule.yaml
      hpa.yaml
    frontend/
      kustomization.yaml
      rollout.yaml
      service.yaml
      virtualservice.yaml
      destinationrule.yaml
      hpa.yaml
  .github/
    workflows/
      ci-cd.yaml        # kustomize 기반 CI/CD (sed 사용 금지)
```
