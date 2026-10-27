# Cost notes

This configuration is designed to stay small, not to guarantee a particular bill. Check the AWS Pricing pages and account billing dashboard for the selected region before applying.

## Illustrative dev estimate

Example estimate for dev in US East (N. Virginia), created with the [AWS Pricing Calculator](https://calculator.aws/#/estimate?id=3b23d04df6b4e3e0d68507e464b92e2545281b52). Anyone with the link can view it.

| Service | Example monthly cost |
|---|---:|
| S3 and DynamoDB | About $0.03 |
| CloudWatch Logs | May be $0 at low usage; depends on log ingestion and storage |
| Standard SSM parameters, IAM, security group | No expected charge at this sample usage |
| EC2 | $0; disabled |
| **Example total** | **About $0.03, plus any CloudWatch usage charges** |

Calculator assumptions: 1 GB of S3 storage, 1,000 writes and 10,000 reads for DynamoDB, and low usage. CloudWatch is not included in the calculator total; log groups alone do not generate logs or ingestion charges. Actual costs depend on usage, free-tier eligibility, and current prices. This is an estimate, not a bill guarantee.

- S3 charges can come from storage, requests, and data transfer. The lifecycle rule expires current objects after the selected period; it does not refund prior usage.
- DynamoDB on-demand billing avoids provisioned capacity but charges for requests and stored data.
- Standard SSM parameters and CloudWatch Logs can incur API, storage, and ingestion charges. Retention limits stored logs, not ingestion.
- IAM and security-group resources have no direct hourly charge.
- EC2 is disabled by default and can exceed the budget if launched or left running. It is restricted to dev and requires an explicit approval variable, but Terraform cannot verify AWS free-tier eligibility.
- No NAT Gateway, load balancer, RDS, EKS, OpenSearch, Elastic IP, or default compute is included.
