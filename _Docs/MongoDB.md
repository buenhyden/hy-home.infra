# MongoDB

## Create User in MongoDB

```
db.createUser({
user: 'hyden',
pwd: '5qsr72YsAynsTyN',
roles: [ { role: 'userAdminAnyDatabase', db: 'admin' } ]
});
```

## Create Role

```
db.createRole(
{
role: "customRoleConfig",
privileges: [
{
actions: [ "collStats", "indexStats" ],
resource: { db: "config", collection: "system.indexBuilds" }
},
{
actions: [ "collStats", "indexStats" ],
resource: { db: "local", collection: "replset.election" }
},
{
actions: [ "collStats", "indexStats" ],
resource: { db: "local", collection: "replset.initialSyncId" }
},
{
actions: [ "collStats", "indexStats" ],
resource: { db: "local", collection: "replset.minvalid" }
},
{
actions: [ "collStats", "indexStats" ],
resource: { db: "local", collection: "replset.oplogTruncateAfterPoint" }
}],
roles: [] })
```

## Grant Role

```
db.grantRolesToUser( "root", [ {role: "customRoleConfig", db: "admin" }])

db.grantRolesToUser('root', [{ role: 'root', db: 'local' }])

db.grantRolesToUser( "hyden", [ {role: "userAdminAnyDatabase", db: "admin" }])
```
