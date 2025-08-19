Terraform for S3 + CloudFront static site hosting

Pre-requisites:
- An S3 bucket to hold Terraform state (backend), e.g. tf-state-<org>-<env>
- A DynamoDB table for state locking with primary key 'LockID'

You can create a simple bootstrap script or manually create these resources.
Example (AWS CLI):
  aws s3api create-bucket --bucket <tf-state-bucket> --region us-east-1
  aws dynamodb create-table --table-name <tf-lock-table> --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST

How to use:
1. Populate the following variables when running terraform init/plan/apply:
   - tf_state_bucket (backend S3 bucket name)
   - tf_lock_table (DynamoDB table name)
   - site_bucket_name (S3 bucket name for site)
   - region (aws region)

2. Initialize:
   terraform init -backend-config="bucket=<tf_state_bucket>" -backend-config="region=<region>" -backend-config="dynamodb_table=<tf_lock_table>"

3. Plan:
   terraform plan -var="site_bucket_name=<site_bucket_name>" -var="region=<region>"

Notes:
- This module configures an S3 bucket with versioning, SSE-S3 and blocks public access. CloudFront OAI is used to grant CloudFront access to the bucket.
- Do NOT run terraform apply from CI automatically. Apply should be run manually by an operator after review and secrets setup.
