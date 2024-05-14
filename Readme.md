# Spinkube demo

## Deploy

Run terraform to deploy the infrastructure
```bash
cd deployment/terraform
terraform init
terraform apply
```

```bash
cd ../flux
kubectl apply -k .
```