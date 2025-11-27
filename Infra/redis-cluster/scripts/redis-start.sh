#!/bin/sh
set -eu

# secret 파일에서 패스워드 읽기
REDIS_PASSWORD=$(cat /run/secrets/redis_password)

# NODE_NAME은 compose 환경변수에서 들어오도록 가정
NODE_NAME="${NODE_NAME:-$(hostname)}"

exec redis-server /usr/local/etc/redis/redis.conf \
  --requirepass "$REDIS_PASSWORD" \
  --masterauth "$REDIS_PASSWORD" \
  --cluster-announce-ip "$NODE_NAME" \
  --cluster-announce-port 6379 \
  --cluster-announce-bus-port 16379
