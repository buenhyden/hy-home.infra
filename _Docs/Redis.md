# Redis

## Redis Cluster 설정

```
redis-cli --pass xtM6wEiKg6J4Rdc --cluster call redis-node-1:6379 flushall
redis-cli --pass xtM6wEiKg6J4Rdc --cluster call redis-node-1:6379 cluster reset
redis-cli --pass xtM6wEiKg6J4Rdc --cluster call redis-node-2:6379 cluster reset
redis-cli --pass xtM6wEiKg6J4Rdc --cluster call redis-node-3:6379 cluster reset
```

```
redis-cli --pass xtM6wEiKg6J4Rdc --cluster create redis-node-1:6379 redis-node-2:6379 redis-node-3:6379
```

```
redis-cli --pass xtM6wEiKg6J4Rdc --cluster add-node redis-node-0-slave:6380 redis-node-0:6379 --cluster-slave
redis-cli --pass xtM6wEiKg6J4Rdc --cluster add-node redis-node-1-slave:6382 redis-node-1:6381 --cluster-slave
redis-cli --pass xtM6wEiKg6J4Rdc --cluster add-node redis-node-2-slave:6384 redis-node-2:6383 --cluster-slave

redis-cli --pass xtM6wEiKg6J4Rdc --cluster create redis-node-0:6379 redis-node-1:6381 redis-node-2:6383 redis-node-0-slave:6380 redis-node-1-slave:6382 redis-node-2-slave:6384 --cluster-replicas 1

redis-cli --pass xtM6wEiKg6J4Rdc --cluster check redis-node-0:6379

redis-cli --pass xtM6wEiKg6J4Rdc -h predixy -p 7617 info
redis-cli --pass ZwgH9A4b5HCbGFbq -h predixy -p 7617 info

redis-cli --pass xtM6wEiKg6J4Rdc -h predixy -p 7617 set test success
redis-cli --pass xtM6wEiKg6J4Rdc -p 7617 -h predixy get **hello**
```
