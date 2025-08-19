Infra: S3 + CloudFront hosting (Terraform)

This change adds Terraform configuration to provision an S3-backed static site served via CloudFront.

CI / Workflow:
- A GitHub Actions workflow (.github/workflows/deploy-site.yml) is added to:
  - Build the site (npm) if package.json exists
  - Upload built assets to the SITE_BUCKET on push to main
  - Run terraform fmt & plan on pull_request and on push

Required repository secrets (set these in GitHub repository Settings -> Secrets):
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION
- SITE_BUCKET          (the S3 bucket name used by the 'Upload to S3' step)
- TF_STATE_BUCKET      (Terraform backend S3 bucket name)
- TF_LOCK_TABLE        (Terraform DynamoDB table name)

Recommended minimal IAM permissions for the CI user (least-privilege):

S3 permissions (for SITE_BUCKET):
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::${SITE_BUCKET}",
        "arn:aws:s3:::${SITE_BUCKET}/*"
      ]
    }
  ]
}

Terraform backend permissions (TF_STATE_BUCKET + TF_LOCK_TABLE):
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::<TF_STATE_BUCKET>",
        "arn:aws:s3:::<TF_STATE_BUCKET>/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:UpdateItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/<TF_LOCK_TABLE>"
    }
  ]
}

Next steps after merging PR:
- Create the TF_STATE_BUCKET and TF_LOCK_TABLE or run a bootstrap script to create them.
- Add required repository secrets listed above.
- Run terraform init/plan and then manually terraform apply as appropriate.
