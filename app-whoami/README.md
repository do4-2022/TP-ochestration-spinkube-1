# Spinkube whoami

## Build

```sh
spin build
```

## Publish to docker 

First, login : 

```sh
spin registry login index.docker.io
```

Then upload (you may need to change the url and tag) : 

```sh
spin registry push index.docker.io/sautax/variable-explorer:v1
```

## Deployment

Needs to have the pod information set as environment variables (via `fieldRef`, see `deploy.yml`) : 

- pod_name : metadata.name
- pod_namespace : metadata.namespace
- pod_uid : metadata.uid
- pod_ip : status.podIP
- node_name : spec.nodeName
- host_ip : status.hostIP