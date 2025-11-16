# hy-home-infra

Kind 기반 `docker-desktop` 클러스터를 대상으로 하는 GitOps 인프라 리포지터리.

## 전체 구조

- `argo/root-app.yaml`: Argo CD App-of-Apps. `clusters/docker-desktop` 하위를 모두 관리.
- `clusters/docker-desktop`:
  - `namespaces/`: 네임스페이스 정의 및 PSA 레이블.
  - `infra/`: MetalLB, StorageClass, cert-manager, Istio, Observability, Kyverno, Argo CD/Rollouts 등 Argo Application 정의.
  - `apps/`: 서비스(백엔드, 프론트엔드) Kustomize 베이스 및 overlay.
  - `secrets/`: SOPS로 암호화된 Secret 파일(`*.enc.yaml`).

## 사용 흐름(개요)

1. Docker Desktop + kind 클러스터(`docker-desktop`) 생성.
2. Argo CD를 별도 설치 후(부트스트랩), `argo/root-app.yaml` 을 `kubectl apply` 로 올려 App-of-Apps 구성.
3. Argo CD에서 `hy-home-infra` 리포를 바라보도록 설정.
4. `root-app` 를 Sync 하면:
   - 네임스페이스 생성
   - MetalLB, StorageClass, cert-manager, Istio, Observability, Kyverno, Argo CD/Rollouts 등 설치
   - 백엔드/프론트엔드 Rollout + HPA 배포

## Secrets 관리

- 모든 비밀번호/토큰 등은 `clusters/docker-desktop/secrets/*.enc.yaml` 로 관리.
- 이 파일들은 SOPS + Age 로 암호화된 상태로 커밋한다.
- 이 문서에 적힌 예시는 암호화 *전* 템플릿이며, 실제 값으로 교체 후 `sops` 로 암호화해야 한다.
