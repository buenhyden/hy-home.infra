#!/bin/sh
set -eu

REDIS_PASSWORD=$(cat /run/secrets/redis_password)

echo "Waiting for Redis nodes to be healthy..."
sleep 10

# 이미 클러스터가 구성되어 있으면 skip
if redis-cli -a "$REDIS_PASSWORD" -h redis-node-0 -p 6379 cluster info 2>/dev/null | grep -q "cluster_state:ok"; then
  echo "Cluster already configured. Skipping cluster creation."
  exit 0
fi

echo "Creating Redis Cluster (3 masters, 3 replicas)..."

# 비대화형 클러스터 생성 (--cluster-yes)
redis-cli -a "$REDIS_PASSWORD" --cluster create \
  redis-node-0:6379 \
  redis-node-1:6379 \
  redis-node-2:6379 \
  redis-node-3:6379 \
  redis-node-4:6379 \
  redis-node-5:6379 \
  --cluster-replicas 1 \
  --cluster-yes

echo "Cluster creation completed."
