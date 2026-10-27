# Architecture

Each environment is configured with its own file under `envs/`. The same Terraform root manages the selected AWS region; optional services are controlled by variables in the selected file. Per assignment, apply and destroy dev only; staging and prod are plan-only.

```mermaid
%%{init: {"theme": "base", "themeVariables": {"background": "#ffffff", "mainBkg": "#ffffff", "fontFamily": "Segoe UI, Arial, sans-serif", "fontSize": "14px", "primaryTextColor": "#263746", "lineColor": "#8796a3", "edgeLabelBackground": "#ffffff"}, "flowchart": {"curve": "linear", "nodeSpacing": 38, "rankSpacing": 54, "htmlLabels": true}}}%%
flowchart TB
  subgraph INPUTS["ENVIRONMENT CONFIGURATION"]
    direction LR
    ENV["Environment tfvars<br/>dev · staging · prod"] --> TF["Terraform root<br/>AWS provider · variables · names · tags"]
  end

  CI["GitHub Actions<br/>TFLint · format · validate"]

  subgraph AWS["AWS ACCOUNT · selected region"]
    direction TB

    subgraph CORE["BASELINE RESOURCES"]
      direction LR
      S3["Amazon S3<br/>Private bucket"]
      VPC["Default VPC"] --> SG["Security group<br/>SSH only from supplied CIDRs"]
    end

    subgraph OPTIONAL["OPTIONAL RESOURCES · variable controlled"]
      direction LR
      IAM["IAM role<br/>Scoped policy"]
      DDB["DynamoDB<br/>PAY_PER_REQUEST"]
      SSM["SSM Parameter Store<br/>Standard String"]
      CW["CloudWatch Logs<br/>Per-environment retention"]
      EC2["EC2 test instance<br/>Dev only · off by default"]
    end
  end

  TF --> CORE
  TF -.-> OPTIONAL
  CI -. "checks only · no deployment" .-> TF
  IAM -. "scoped permissions" .-> S3
  IAM -. "parameter reads" .-> SSM
  SG -. "attached if EC2 enabled" .-> EC2

  classDef config fill:#eef3f8,stroke:#8da0af,color:#263746,stroke-width:1.2px
  classDef core fill:#edf4ef,stroke:#91a99a,color:#294337,stroke-width:1.2px
  classDef optional fill:#f5f2eb,stroke:#b2a488,color:#443e32,stroke-width:1.2px
  class ENV,TF,CI config
  class S3,VPC,SG core
  class IAM,SSM,DDB,CW,EC2 optional
  style INPUTS fill:#ffffff,stroke:#c8d2da,color:#344653,stroke-width:1px
  style AWS fill:#ffffff,stroke:#aebdc8,color:#344653,stroke-width:1.2px
  style CORE fill:#ffffff,stroke:#c8d6cd,color:#3d5547,stroke-width:1px
  style OPTIONAL fill:#ffffff,stroke:#ded6c6,color:#554c3d,stroke-width:1px
```

Solid arrows show configuration flow and the default-VPC relationship. Dashed arrows show validation, optional provisioning, IAM policy scope, and the conditional EC2 security-group attachment. The IAM role has an EC2 trust policy but is not attached to the test instance. CI runs checks only; it does not apply infrastructure.

The bucket is private. The supplied tfvars files use `us-east-1`; other configured regions are selected through the environment setting. DynamoDB is on-demand, SSM values are standard-tier strings, and log retention is configured per environment.

The supplied environment files enable DynamoDB, IAM, SSM, and CloudWatch logs. S3 versioning is off in dev and on in staging and prod; lifecycle expiration is enabled in all three. EC2 is off in every supplied environment and is restricted to dev with explicit approval.

No Terraform modules are used. Resource names are assembled in `locals.tf` from company, project, the `owner` and `student_id` variables, environment, resource type, and region; for example, `bjit-tfassign-sumaiya-30245-dev-config-table-use1`.

The repository includes AWS screenshots and an earlier apply attempt that reported existing resources. Verify the current AWS account and Terraform state before applying or destroying; do not assume the diagram means resources are absent or that Terraform currently manages them.

## Design decisions

- One flat Terraform root keeps the assignment easy to inspect; environment differences are inputs from separate tfvars files rather than copied configurations.
- A shared naming prefix combines company, project, owner, student ID, environment, resource type, and region to make ownership and environment clear in AWS.
- `count` is used for optional singleton resources, while `for_each` creates parameter and log-group resources from keyed maps.
- Optional features are controlled by variables, and IAM permissions are limited to the application's bucket and SSM parameters.
- Cost-sensitive or risky resources are constrained: EC2 is opt-in and dev-only, SSH ingress is empty unless CIDRs are supplied, and log retention is bounded.
