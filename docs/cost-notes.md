# Cost notes

This configuration is designed to stay small, not to guarantee a particular bill. Check the AWS Pricing pages and account billing dashboard for the selected region before applying.

- S3 charges can come from storage, requests, and data transfer. The lifecycle rule expires current objects after the selected period; it does not refund prior usage.
- DynamoDB on-demand billing avoids provisioned capacity but charges for requests and stored data.
- Standard SSM parameters and CloudWatch Logs can incur API, storage, and ingestion charges. Retention limits stored logs, not ingestion.
- IAM and security-group resources have no direct hourly charge.
- EC2 is disabled by default and can exceed the budget if launched or left running. It is restricted to dev and requires an explicit approval variable, but Terraform cannot verify AWS free-tier eligibility.
- No NAT Gateway, load balancer, RDS, EKS, OpenSearch, Elastic IP, or default compute is included.

Apply only dev, inspect the plan before approval, monitor actual billing, and destroy dev after verification. Staging and prod are plan-only. The prod `prevent_destroy` tfvars flag records intent but cannot drive Terraform's literal-only `lifecycle.prevent_destroy`; the README explains the limitation.