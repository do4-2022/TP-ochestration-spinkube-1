# Spinkube demo

## Deploy

```bash
cd deployment/terraform
terraform init
terraform apply -auto-approve
```

Then wait a bit for the cluster to be ready and for flux to deploy the applications.

## Test the deployment


### Test the queue scaling
From the rabbitmq pod:
Create a queue
```bash
curl -u user:password -XPUT -H "content-type:application/json" \
    http://localhost:15672/api/queues/%2F/testqueue \
    -d'{"durable":true}'
```

Send a message
```bash
curl -u user:password -XPOST -H "content-type:application/json" \
    http://localhost:15672/api/exchanges/%2F/amq.default/publish \
    -d'{"properties":{},"routing_key":"testqueue","payload":"Hello, World!","payload_encoding":"string"}'
```

Empty the queue
```bash
curl -u user:password -XDELETE -H "content-type:application/json" \
    http://localhost:15672/api/queues/%2F/testqueue/contents
```

### Test the http scaling
From localhost:
Get the external ip of the service
```bash
kubectl get svc --namespace traefik
```

put cluster ip in /etc/hosts
```bash
echo "<EXTERNAL_IP> whoami.example.com" | sudo tee -a /etc/hosts
```

Test the service
```bash
curl whoami.example.com
```