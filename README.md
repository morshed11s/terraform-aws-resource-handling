# AWS Terraform Assignment

## Project purpose

This is a single-root, flat-file Terraform learning project for dev, staging, and prod. Select an environment by passing its file under `envs/`; the configuration does not use Terraform modules. This repository contains configuration only: no AWS resources have been applied.

## Architecture overview

The root configuration manages an application S3 bucket, optional PAY_PER_REQUEST DynamoDB table, optional least-privilege IAM role and policy, standard-tier SSM String parameters, short-retention CloudWatch log groups, a security group, and an optional dev-only EC2 test instance. See [docs/architecture.md](docs/architecture.md).

## Folder structure

```text
.
|-- versions.tf / providers.tf / variables.tf / locals.tf / data.tf
|-- s3.tf / dynamodb.tf / iam.tf / ssm.tf / cloudwatch.tf
|-- security-group.tf / ec2-optional.tf / outputs.tf
|-- backend-example.tf
|-- Makefile
|-- .tflint.hcl
|-- .github/workflows/terraform.yml
|-- envs/       dev.tfvars, staging.tfvars, prod.tfvars
|-- docs/       architecture.md, cost-notes.md
`-- evidence/   command-output placeholders
```

There is intentionally no `modules/` directory.

## AWS services used

- S3: private application/config bucket, ownership controls, public access blocks, optional versioning and expiration lifecycle rule.
- DynamoDB: optional configuration table with `PAY_PER_REQUEST` billing.
- IAM: optional EC2 trust role and policy scoped to this bucket and this environment's parameters.
- Systems Manager Parameter Store: optional standard-tier `String` values only. Never put secrets in these sample tfvars.
- CloudWatch Logs: optional log groups with short, configured retention.
- VPC security group: created in the account's default VPC; no ingress unless CIDRs are explicitly supplied.
- EC2: optional, dev-only `t3.micro`, disabled in every supplied tfvars file. It can incur charges and needs explicit free-tier approval.

No NAT Gateway, load balancer, database, EKS, OpenSearch, Elastic IP, or always-on compute is configured.

## Cost estimate and cost safety rules

The project targets the assignment's under-$5 limit, but actual AWS charges depend on account, region, usage, and current pricing; no fixed estimate is a guarantee. S3 storage/requests, Parameter Store API use, log ingestion, and any EC2 runtime can incur charges. DynamoDB uses on-demand billing but is not inherently free. Review [docs/cost-notes.md](docs/cost-notes.md) before applying.

Safety defaults: EC2 is off; SSH CIDRs are empty; SSM values are non-secret; log retention is limited; no networking or compute charges are introduced by default. Apply only dev, inspect resources and billing, then destroy dev as the assignment requires. Staging and prod are plan-only.

### Production destroy protection limitation

`prevent_destroy` is accepted and validated as an environment intent flag (`false` for dev/staging and `true` for prod). Terraform requires `lifecycle { prevent_destroy = ... }` to be a literal in configuration; it cannot be driven by a `.tfvars` value. With one root configuration and only tfvars changing, Terraform cannot provide variable-controlled lifecycle protection. The prod S3 precondition verifies the required intent and core settings, but it does **not** block `terraform destroy`. Treat prod as plan-only and do not apply or destroy it. For real protection, use a separate prod root/configuration with literal lifecycle guards or enforce deletion controls outside this assignment's single-root constraint.

## How to run dev

Prerequisites: Terraform 1.9 or newer, AWS CLI credentials configured for a dedicated learning account, and access to a default VPC in the selected region. The S3 bucket name must be globally unique; if the supplied name is taken, change `company` or `project` consistently in the tfvars files.

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file="envs/dev.tfvars" -out="dev.tfplan"
```

Review the plan carefully. Only after confirming the account, region, resource list, and cost exposure should you apply:

```powershell
terraform apply "dev.tfplan"
terraform output
```

Do not run apply for staging or prod. Record actual command output in the matching evidence files; the checked-in evidence files are placeholders, not claims that commands have been run.

## How to plan staging and prod

Plans may refresh AWS state and require credentials, but do not create resources:

```powershell
terraform plan -var-file="envs/staging.tfvars"
terraform plan -var-file="envs/prod.tfvars"
```

The assignment says staging and prod are plan-only. Keep them that way.

## How to destroy dev resources

After verification, destroy only the dev workspace/state:

```powershell
terraform destroy -var-file="envs/dev.tfvars"
```

Confirm the environment and Terraform state before approving the destroy prompt. This is local state by default; do not share a state file across environments.

## Bonus tooling

The Makefile provides shortcuts for formatting, validation, environment plans, and the dev destroy command. GNU Make must be installed and available on `PATH`:

```sh
make fmt
make validate
make plan-dev
make plan-staging
make plan-prod
make destroy-dev
```

`make destroy-dev` deletes resources managed by the selected dev state; inspect the plan and confirm the prompt before proceeding. The `tflint` target requires TFLint to be installed and downloads the AWS ruleset on its first run:

```sh
make tflint
```

GitHub Actions runs `terraform fmt -check -recursive` and `terraform validate` on pushes and pull requests. It initializes with `-backend=false`, so it does not need AWS credentials or access to a remote state backend.

The commented S3 backend example in [backend-example.tf](backend-example.tf) shows remote state encryption and DynamoDB state locking. Create the bucket and lock table separately before enabling it, then migrate state with `terraform init -migrate-state`. Keep backend configuration and credentials out of source control.

## Terraform features demonstrated

- Environment-specific behavior through `envs/dev.tfvars`, `envs/staging.tfvars`, and `envs/prod.tfvars`.
- Conditional naming via locals for company, project, owner and student ID variables, environment, resource type, and region short names.
- `count` for optional singleton resources; `for_each` for SSM parameters and CloudWatch log groups.
- Dynamic blocks for optional S3 lifecycle rules, IAM policy statements, and security-group ingress rules.
- Variable validation for environment, identifiers, supported regions, lifecycle/retention values, CIDRs, production tags, and cost-sensitive EC2 settings.
- Null-safe outputs for optional resources.

## Known limitations

- Resource names follow the assignment pattern but S3 names are globally unique. Pick a distinct company/project slug when the sample name is unavailable.
- The security group and EC2 AMI data source rely on a default VPC/subnet in the selected region. The AMI lookup runs only when optional EC2 is enabled.
- `prevent_destroy` cannot be selected by tfvars in Terraform lifecycle metadata. See the production destroy protection section.
- The commented backend example is documentation only. Local state is used until a separately provisioned remote-state bucket and lock table are configured.
- Parameter values are plain-text example configuration and must not contain secrets.

## Submission checklist

Create a Git repository, capture the folder structure, run the commands required by the assignment, and replace each evidence placeholder with actual output. Include a short explanation of naming, `count` versus `for_each`, dynamic blocks, tfvars, and cost controls.