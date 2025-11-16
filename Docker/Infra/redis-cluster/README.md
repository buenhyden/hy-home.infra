# redis-1 컨테이너 내부로 접속

```bash
docker exec -it redis-1 sh

# redis-cli를 사용하여 클러스터 생성 (컨테이너 이름 사용)

# (주의: 이 명령어는 컨테이너 내부에서 실행합니다)

# (IP 대신 컨테이너 이름을 사용하려면 --cluster-announce-ip 옵션 등이 필요할 수 있습니다)

#

# [수정] 가장 간단한 방법은 호스트에서 `redis-cli`를 사용하는 것입니다

# 또는, `redis-cli`가 있는 `redis-1` 컨테이너에서 다른 노드를 IP로 참조해야 합니다

#

# [권장] `docker inspect`로 6개 컨테이너의 `hy-home-net` IP를 확인한 후 실행합니다

# 예: 172.19.0.5 ~ 172.19.0.10

# redis-1 컨테이너에서 redis-cli 실행 (비밀번호 포함)
# 2. redis-cli로 클러스터 생성 (모든 포트를 6379로 지정)
docker exec -it redis-1 redis-cli \
  -a "$REDIS_PASSWORD" \
  --cluster create \
  redis-1:6379 redis-2:6379 redis-3:6379 \
  redis-4:6379 redis-5:6379 redis-6:6379 \
  --cluster-replicas 1 \
  --cluster-yes
```
