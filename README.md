# hy-home-infra

“실사용 환경에서 Managed 많이 쓰는 것 → Docker(외부 클러스터)”, “서비스/게이트웨이/정책/관찰성 → Kind(Kubernetes)” 원칙
## 전체 아키텍처 개요

| 역할           | 구성요소                                                  | 배치                                               | 비고                                                            |
| ------------ | ----------------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------- |
| 데이터베이스       | PostgreSQL(HA)                                        | **Docker Compose**                               | Spilo 기반 HA 클러스터 (첨부 compose 활용)                              |
| 캐시           | Redis Cluster                                         | **Docker Compose**                               | Redis 8.x cluster, exporter 포함                                |
| 스트리밍         | Kafka(KRaft) + Schema Registry + Connect + REST Proxy | **Docker Compose**                               | Confluent cp-kafka 7.7.x (Kafka 3.7, LTS 계열)                  |
| 검색           | OpenSearch Cluster                                    | **Docker Compose**                               | OpenSearch 3.x 계열 (3.3.x)                                     |
| 오브젝트 스토리지    | MinIO                                                 | **Docker Compose**                               | coollabsio/minio 기반 (공식 minio 이미지 유료화 이후 대안)                  |
| 수집/전달        | Grafana Alloy                                         | **Kind DaemonSet + 일부 sidecar + Docker 1개 컨테이너** | K8s 노드/Pod + Docker 컨테이너 로그/메트릭/Trace 수집                      |
| 로그 저장        | Loki                                                  | **Kind**                                         | grafana/loki 헬름 차트 사용                                         |
| Trace 저장     | Tempo                                                 | **Kind**                                         | grafana/tempo-distributed 헬름 차트                               |
| 메트릭/대시보드     | kube-prometheus-stack(+Grafana)                       | **Kind**                                         | prometheus-community/kube-prometheus-stack                    |
| GitOps       | Argo CD + Image Updater + Notifications               | **Kind**                                         | argo/argo-cd 공식 chart/매니페스트                                   |
| 배포 전략        | Argo Rollouts                                         | **Kind**                                         | 카나리 + Istio 연동                                                |
| 시크릿 암호화      | Sealed Secrets                                        | **Kind**                                         | bitnami-labs/sealed-secrets (유일한 Bitnami 계열, 필요시 SOPS로 대체 가능) |
| 서비스 메시/게이트웨이 | Istio + Istio IngressGateway                          | **Kind**                                         | Istio 1.27.x LTS 계열                                           |
| 인그레스 LB      | MetalLB                                               | **Kind**                                         | 172.18.200.100–199 풀 사용                                       |
| 보안/정책        | Kyverno + PSA + NetworkPolicy                         | **Kind**                                         | Kyverno 1.16.x                                                |
| 인증서          | cert-manager                                          | **Kind**                                         | jetstack/cert-manager v1.16.x                                 |
| 워크플로우        | Airflow, n8n                                          | **Kind**                                         | Airflow 공식 chart, n8n K8s Deployment                          |
| 서비스          | Python Backend, React Frontend                        | **Kind**                                         | Argo Rollouts(카나리) + Istio Gateway + HPA                      |


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
