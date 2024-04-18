# api-gateway
Amazon API Gateway for mTLS testing with open-source cloud certificate authority

## Local Deployment - Terraform
```
terraform init -backend-config=bucket={YOUR_TERRAFORM_STATE_BUCKET} -backend-config=key=cloud-ca -backend-config=region={YOUR_TERRAFORM_STATE_REGION}
terraform plan
terraform apply
```