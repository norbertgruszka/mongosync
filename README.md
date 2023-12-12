# `mongosync` pod

## Build Docker

Image is build with each merge to `main` branch. For specific version, set a tag. That will trigger new build.

## Create `mongosync-user` user

Login to destintation and source database. Start `mongosh` and execute following commands:

```js
db.adminCommand( {
   createRole: "reverseSync",
   privileges: [ {
       resource: { db: "", collection: "" },
       actions: [ "setUserWriteBlockMode", "bypassWriteBlockingMode" ]
   } ],
   roles: []
} )
use admin
db.createUser(
   {
     user: "mongosync-user",
     pwd: "<strong-password>",
     roles: [ "readWrite", "dbAdmin", "reverseSync"]
   }
)
```

If you have doubts regarding roles required by `mongosync`, please refer to [official documentation](https://www.mongodb.com/docs/cluster-to-cluster-sync/current/connecting/onprem-to-onprem/#roles).

## Deploy on `mongosync` service on Kubernetes cluster

Create new namespace

```bash
kubectl create namespace infra-mongosync
```

Prepare connection strings to both source and destination MongoDB databases. For example:

```bash
export MONGOSYNC_CLUSTER_0=mongodb://mongosync-user:<strong-password>@mongos.mongodb.svc.cluster.local:27017
export MONGOSYNC_CLUSTER_1=mongodb://mongosync-user:<strong-password>@192.168.32.64:27017
```

Store those strings as `mongosync-secret` as follows

```bash
kubectl -n infra-mongosync create secret generic mongosync-secrets --from-literal="MONGOSYNC_CLUSTER_0=${MONGOSYNC_CLUSTER_0}" --from-literal="MONGOSYNC_CLUSTER_1=${MONGOSYNC_CLUSTER_1}"
```

Deploy `mongosync` pod.

```bash
kubectl apply -f ./mongosync.yml
```

Expose port to `mongosync`

```bash
kubectl -n infra-mongosync port-forwards svc/mongosync 27182:27182
```

Verify connection to `mongosync` pod.

```bash
curl http://localhost:27182/api/v1/progress
```

## Start migration

```bash
curl localhost:27182/api/v1/start -XPOST --data @payload.json
```
