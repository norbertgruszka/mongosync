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

Update `cluster0` and `cluster1` fields in `./manifests/mongosync-cm.yml` file and apply it.

```bash
kubectl apply -f ./manifests/mongosync-cm.yml
```

Next, deploy `mongosync` pod.

```bash
kubectl apply -f ./manifests/mongosync-deployment.yml
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
