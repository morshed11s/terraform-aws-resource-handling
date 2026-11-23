# AWS Terraform (provisioning)

## Project overview

This is a flat, single-root Terraform project for managing dev, staging, and prod configurations in AWS. The same Terraform files are reused; an environment is selected with its corresponding file in `envs/`. The project demonstrates Terraform fundamentals and AWS resource configuration. No Terraform modules are used.

## Latest deployment status

The latest recorded dev destroy completed successfully: `evidence/destroy-dev.txt` reports **14 resources destroyed**. This describes resources tracked by that Terraform state at the time of the command; it does not establish that unrelated or manually created AWS resources are absent. Check the AWS account and state before any new plan, apply, or destroy.

## Repository structure

Each file is listed on its own line for readability. Generated Terraform state, plans, and the `.terraform/` working directory are local-only and are intentionally not listed here.

```text
.
├── .github/
│   └── workflows/
│       └── terraform.yml
├── docs/
│   ├── architecture.md
│   └── cost-notes.md
├── envs/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
├── evidence/
│   ├── screenshots/
│   │   ├── Makefile.png
│   │   ├── T3cloudwatch-dev-app-logs.png
│   │   ├── T3cloudwatch-dev-worker-logs.png
│   │   ├── T3dynamodbTable.png
│   │   ├── T3s3bucket.png
│   │   ├── T3s3bucketPermissions.png
│   │   ├── T3s3bucketProperties.png
│   │   ├── T3securitygroup.png
│   │   ├── costCalculator.png
│   │   ├── github actions pipeline.png
│   │   ├── ssmParameter-dev-feature-flag.png
│   │   ├── ssmParameter-dev-log-level-parameter.png
│   │   ├── ssmPrameter-dev-app-name.png
│   │   ├── tflint.png
│   │   └── tflintGithubActions.png
│   ├── apply-dev.txt
│   ├── destroy-dev.txt
│   ├── output-dev.txt
│   ├── plan-dev.txt
│   ├── plan-prod.txt
│   ├── plan-staging.txt
│   ├── terraform-fmt.txt
│   ├── terraform-init.txt
│   ├── terraform-plan-dev.txt
│   └── terraform-validate.txt
├── .gitignore
├── .tflint.hcl
├── .terraform.lock.hcl
├── Makefile
├── README.md
├── backend-example.tf
├── cloudwatch.tf
├── data.tf
├── dynamodb.tf
├── ec2-optional.tf
├── iam.tf
├── locals.tf
├── outputs.tf
├── providers.tf
├── s3.tf
├── security-group.tf
├── ssm.tf
├── variables.tf
└── versions.tf
```

The `.terraform/` directory, `terraform.tfstate`, `terraform.tfstate.backup`, and `*.tfplan` files are generated locally. Keep them out of source control; state and plan files may contain sensitive information.

## Architecture and resources

See [docs/architecture.md](docs/architecture.md) for the architecture diagram and design explanation. The project configures:

- **Amazon S3:** private application bucket, ownership controls, public-access blocks, environment-specific versioning, and optional lifecycle expiration.
- **Amazon DynamoDB:** optional configuration table using `PAY_PER_REQUEST`.
- **AWS IAM:** optional EC2 trust role and a scoped policy for the application bucket and configured SSM parameters.
- **AWS Systems Manager Parameter Store:** optional Standard-tier `String` parameters. Sample values are configuration only; do not put secrets in tfvars.
- **Amazon CloudWatch Logs:** optional log groups with retention set per environment. This configuration creates groups but does not itself send logs to them.
- **VPC security group:** created in the default VPC. SSH ingress is absent unless approved CIDR blocks are supplied; egress is open.
- **Amazon EC2:** optional dev-only `t3.micro` test instance, disabled in all supplied environment files, with explicit approval required to enable it.

No NAT Gateway, load balancer, RDS database, EKS, OpenSearch, Elastic IP, or always-on compute is configured.

### Resource naming

Names use the company, project, owner, student ID, environment, resource type, and short region code. For example, the dev DynamoDB table name is:

```text
organization-tfassign-owner-student_id-dev-config-table-use1
```

The `owner` and `student_id` variables are set in each environment's tfvars file. Adjust these values if needed; S3 bucket names must also be globally unique.

### Terraform patterns demonstrated

- Environment-specific configuration through `envs/dev.tfvars`, `envs/staging.tfvars`, and `envs/prod.tfvars`.
- Locals for consistent resource names, region short names, and shared tags.
- `count` for optional singleton resources and `for_each` for SSM parameters and CloudWatch log groups.
- Dynamic blocks for the optional S3 lifecycle rule, IAM policy statement, and security-group ingress rules.
- Variable validation for environment, naming identifiers, supported AWS regions, retention values, CIDRs, production tags, and EC2 approval.
- Outputs that handle optional resources.

## Environment behavior

| Setting | Dev | Staging | Prod |
|---|---|---|---|
| S3 versioning | Off | On | On |
| S3 lifecycle expiration | 7 days | 30 days | 90 days |
| DynamoDB, IAM, SSM, CloudWatch Logs | Enabled | Enabled | Enabled |
| CloudWatch log retention | 7 days | 14 days | 30 days |
| EC2 test instance | Off | Off | Off |
| `prevent_destroy` intent variable | `false` | `false` | `true` |

The assignment requires applying dev only; staging and prod are plan-only. Do not apply or destroy staging or prod.

## Prerequisites

- Terraform 1.9 or newer.
- AWS CLI credentials for the intended learning account and permission to manage the selected resources.
- A default VPC in the selected region.
- GNU Make to use the Makefile targets.
- TFLint to run the local linter target.

Run commands from the repository root in PowerShell. Ensure the AWS account and region are correct before planning or applying. `aws_region` is currently `us-east-1` in all supplied tfvars files.

## Required Terraform commands

The assignment requires running these commands and saving the actual output under `evidence/`. These PowerShell examples use `Tee-Object` to display output in the terminal while saving it. Check each command's exit status; do not treat an error log as a successful run or replace evidence with fabricated or edited output.

Initialize Terraform:

```powershell
terraform init 2>&1 | Tee-Object -FilePath "evidence\terraform-init.txt"
```

Format all Terraform files:

```powershell
terraform fmt -recursive 2>&1 | Tee-Object -FilePath "evidence\terraform-fmt.txt"
```

Validate the configuration:

```powershell
terraform validate 2>&1 | Tee-Object -FilePath "evidence\terraform-validate.txt"
```

Create and save the dev plan:

```powershell
terraform plan -var-file="envs/dev.tfvars" -out="dev.tfplan" 2>&1 | Tee-Object -FilePath "evidence\plan-dev.txt"
```

Review the plan carefully before applying. Applying can create billable resources:

```powershell
terraform apply "dev.tfplan" 2>&1 | Tee-Object -FilePath "evidence\apply-dev.txt"
```

Show Terraform outputs:

```powershell
terraform output 2>&1 | Tee-Object -FilePath "evidence\output-dev.txt"
```

After verifying dev resources, destroy only the intended dev resources. This is destructive; review Terraform's proposed deletions and confirm only if they are correct:

```powershell
terraform destroy -var-file="envs/dev.tfvars" 2>&1 | Tee-Object -FilePath "evidence\destroy-dev.txt"
```

Create staging and prod plans for review only:

```powershell
terraform plan -var-file="envs/staging.tfvars" 2>&1 | Tee-Object -FilePath "evidence\plan-staging.txt"
terraform plan -var-file="envs/prod.tfvars" 2>&1 | Tee-Object -FilePath "evidence\plan-prod.txt"
```

Plans can refresh AWS state but do not create resources. Never apply the staging or prod plans for this assignment.

### State and previously observed resources

The evidence in this repository includes an apply attempt that reported several AWS resources already existed. Do not assume the account or Terraform state is empty. Before applying or destroying, inspect the current account, the resources, and Terraform state; import existing resources only if they belong to this project and are intended to be managed here. Do not delete resources merely to make an apply succeed.

The supplied environment files use the same Terraform root and default local state location. Switching tfvars does **not** isolate state. Do not plan or apply another environment against dev state as though it were independent. Staging and prod are plan-only; inspect each plan for unexpected replacements or deletions. Use separate state/workspaces or separately configured backends only if the assignment permits and the state setup is understood.

### Production destroy-protection limitation

Terraform requires `lifecycle { prevent_destroy = ... }` to be a literal in the configuration; a `.tfvars` value cannot set it. The prod S3 precondition checks the `prevent_destroy` intent flag and required settings, but does **not** block `terraform destroy`. Treat prod as plan-only and do not apply or destroy it. Actual deletion protection requires a separate prod root with a literal lifecycle guard or controls outside this single-root assignment.

## Cost estimate and safety

The assignment targets a cost below $5, but this is not guaranteed. See [docs/cost-notes.md](docs/cost-notes.md) for an illustrative dev estimate from the AWS Pricing Calculator and its assumptions. The calculator estimate includes modeled S3 and DynamoDB usage; CloudWatch Logs depends on actual log ingestion/storage and is not included in that calculator total.

Safety reminders:

- EC2 is disabled by default; if enabled, it can incur charges and must be explicitly approved.
- Empty `allowed_cidr_blocks` means no SSH ingress.
- Log retention limits stored log history; it does not limit ingestion charges.
- DynamoDB on-demand billing is usage-based, not inherently free.
- Monitor AWS Billing and Cost Explorer, and destroy dev after completing the assignment.
- Actual prices depend on region, account eligibility, usage, taxes, and current AWS pricing.

## Bonus tooling

### Makefile

The Makefile provides shortcuts. GNU Make must be installed and available on `PATH`.

```sh
make fmt
make validate
make plan-dev
make plan-staging
make plan-prod
make destroy-dev
make tflint
```

`make destroy-dev` is destructive and prompts Terraform to delete resources tracked in the current state. Confirm only after checking the environment, state, and proposed deletions.

### TFLint

The [`.tflint.hcl`](.tflint.hcl) configuration enables the AWS ruleset. `make tflint` initializes its plugin and runs the checks. Install TFLint before running locally.

### GitHub Actions

The workflow at [.github/workflows/terraform.yml](.github/workflows/terraform.yml) runs on pushes to any branch. It runs TFLint, checks Terraform formatting, initializes with `-backend=false`, and validates configuration. It does not apply infrastructure or require AWS credentials.

### Optional S3 backend example

[backend-example.tf](backend-example.tf) contains a commented S3 backend configuration with encryption and DynamoDB locking. The backend is not enabled. Create the state bucket and lock table separately before enabling it, then use `terraform init -migrate-state` if migrating existing state. Do not commit credentials or state data.

