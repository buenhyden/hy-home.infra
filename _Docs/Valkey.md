# Valkey

## Valkey Cluster 설정

```
valkey-cli --pass xtM6wEiKg6J4Rdc --cluster call valkey-node-1:6379 flushall
valkey-cli --pass xtM6wEiKg6J4Rdc --cluster call valkey-node-1:6379 cluster reset
valkey-cli --pass xtM6wEiKg6J4Rdc --cluster call valkey-node-2:6379 cluster reset
valkey-cli --pass xtM6wEiKg6J4Rdc --cluster call valkey-node-3:6379 cluster reset
```

```
valkey-cli --pass xtM6wEiKg6J4Rdc --cluster create valkey-node-1:6379 valkey-node-2:6379 valkey-node-3:6379
```

```
valkey-cli --pass xtM6wEiKg6J4Rdc --cluster add-node valkey-node-0-slave:6380 valkey-node-0:6379 --cluster-slave
valkey-cli --pass xtM6wEiKg6J4Rdc --cluster add-node valkey-node-1-slave:6382 valkey-node-1:6381 --cluster-slave
valkey-cli --pass xtM6wEiKg6J4Rdc --cluster add-node valkey-node-2-slave:6384 valkey-node-2:6383 --cluster-slave

valkey-cli --pass xtM6wEiKg6J4Rdc --cluster create valkey-node-0:6379 valkey-node-1:6381 valkey-node-2:6383 valkey-node-0-slave:6380 valkey-node-1-slave:6382 valkey-node-2-slave:6384 --cluster-replicas 1

valkey-cli --pass xtM6wEiKg6J4Rdc --cluster check valkey-node-0:6379

valkey-cli --pass xtM6wEiKg6J4Rdc -h predixy -p 7617 info
valkey-cli --pass ZwgH9A4b5HCbGFbq -h predixy -p 7617 info

valkey-cli --pass xtM6wEiKg6J4Rdc -h predixy -p 7617 set test success
valkey-cli --pass xtM6wEiKg6J4Rdc -p 7617 -h predixy get **hello**
```
