# Docker 쪽 클러스터(docker-compose)

모든 비밀번호는 .env 파일(또는 Docker Secret)로 분리하고, compose에는 ${POSTGRES_PASSWORD} 같은 참조만 둔다.

# 예: pg-router의 IP 확인

docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pg-router

# 출력 예시: 172.18.0.10

# minio IP 확인

docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' minio

# 출력 예시: 172.18.0.11

# kafka-controller-1의 IP 확인

docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kafka-controller-1

# 출력 예시: 172.18.0.12
