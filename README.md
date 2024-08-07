# api-gateway
Amazon API Gateway for mTLS testing with open-source cloud certificate authority

> 📖 use in conjunction with blog post [API Gateway mTLS with open-source cloud CA](https://medium.com/@paulschwarzenberger/api-gateway-mtls-with-open-source-cloud-ca-3362438445de)

![Alt text](images/api-gateway-with-truststore.png?raw=true "API Gateway mTLS")

* deploys API Gateway and Lambda function using Terraform
* API Gateway allows public API execution and no authentication
* configure mTLS manually using the console as detailed in the [blog](https://medium.com)
* this includes removal of the public execute API endpoint

## Warning

Don't use this Terraform code as-is to deploy a  confidential API Gateway - it has a public execute API endpoint which can be invoked by anyone.

## Local Deployment - Terraform
```
terraform init -backend-config=bucket={YOUR_TERRAFORM_STATE_BUCKET} -backend-config=key=api-gateway -backend-config=region={YOUR_TERRAFORM_STATE_REGION}
terraform plan
terraform apply
```
Alternatively update `backend.tf` with details of your Terraform state S3 bucket.