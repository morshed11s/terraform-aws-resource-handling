# Architecture

Each environment is configured with its own file under `envs/`. The same Terraform root manages the selected AWS region; optional services are controlled by variables in the selected file. Per assignment, apply and destroy dev only; staging and prod are plan-only.

```mermaid
%%{init: {"theme": "base", "themeVariables": {"background": "#ffffff", "mainBkg": "#ffffff", "fontFamily": "Segoe UI, Arial, sans-serif", "fontSize": "14px", "primaryTextColor": "#263746", "lineColor": "#8796a3", "edgeLabelBackground": "#ffffff"}, "flowchart": {"curve": "linear", "nodeSpacing": 38, "rankSpacing": 54, "htmlLabels": true}}}%%
flowchart TB
  subgraph CONFIG["ENVIRONMENT CONFIGURATION · one root codebase, no modules"]
    direction LR
    DEV["envs/dev.tfvars<br/>versioning off · 7-day lifecycle<br/>prevent_destroy false"]
    STG["envs/staging.tfvars<br/>versioning on · closer to prod<br/>prevent_destroy false"]
    PRD["envs/prod.tfvars<br/>versioning on · 90-day lifecycle<br/>prevent_destroy true · stricter tags"]
  end

  subgraph ROOT["TERRAFORM ROOT · flat files"]
    direction LR
    VARS["variables.tf<br/>validation: env · project · lifecycle<br/>EC2 never allowed in prod"]
    LOCALS["locals.tf<br/>name_prefix · env_short · region_short<br/>common_tags"]
    DATA["data.tf<br/>default VPC · caller identity · AMI"]
  end

  subgraph RUN["COMMANDS"]
    direction LR
    APPLY["dev<br/>plan → apply → output → destroy"]
    PLAN["staging · prod<br/>plan only, never applied"]
  end

  subgraph AWS["AWS ACCOUNT · us-east-1 · dev only, destroyed after verification"]
    direction TB

    subgraph CORE["CORE RESOURCES · on in every env, each behind an enable_* flag"]
      direction LR
      S3["s3.tf · Amazon S3<br/>app bucket · ownership controls<br/>public access block · versioning by env<br/>lifecycle rule via dynamic block"]
      DDB["dynamodb.tf · DynamoDB<br/>config table · PAY_PER_REQUEST<br/>count"]
      IAM["iam.tf · IAM role<br/>trust policy · least-privilege policy<br/>dynamic statement"]
      SSM["ssm.tf · SSM Parameter Store<br/>Standard String · for_each"]
      CW["cloudwatch.tf · CloudWatch Logs<br/>app · worker · short retention<br/>for_each"]
    end

    subgraph NET["NETWORK · no cost"]
      direction LR
      VPC["Default VPC<br/>read via data source"] --> SG["security-group.tf<br/>ingress from allowed_cidr_blocks"]
    end

    subgraph OPT["OPTIONAL · off by default"]
      EC2["ec2-optional.tf · EC2 test instance<br/>count = 0 · dev only · never prod"]
    end
  end

  subgraph RESULTS["OUTPUTS AND EVIDENCE"]
    direction LR
    OUT["outputs.tf<br/>names · ARNs · null when disabled"]
    EVD["evidence/<br/>fmt · validate · 3 plans<br/>apply · output · destroy"]
  end

  subgraph BONUS["BONUS · not deployed"]
    direction LR
    CI["GitHub Actions · Makefile<br/>fmt · validate · tflint"]
    BE["backend-example.tf<br/>S3 state + DynamoDB lock design"]
  end

  CONFIG -- "-var-file" --> ROOT
  ROOT --> RUN
  RUN == "apply dev only" ==> AWS
  IAM -. "scoped access" .-> S3
  IAM -. "read params" .-> SSM
  IAM -. "item access" .-> DDB
  IAM -. "write logs" .-> CW
  SG -. "attached if enabled" .-> EC2
  AWS --> RESULTS
  RUN -. "saved outputs" .-> RESULTS
  BONUS -. "checks and design only" .-> ROOT

  classDef config fill:#eef3f8,stroke:#8da0af,color:#263746,stroke-width:1.2px
  classDef core fill:#edf4ef,stroke:#91a99a,color:#294337,stroke-width:1.2px
  classDef optional fill:#f5f2eb,stroke:#b2a488,color:#443e32,stroke-width:1.2px
  classDef result fill:#f3f0f7,stroke:#a89cb8,color:#3a3247,stroke-width:1.2px
  class DEV,STG,PRD,VARS,LOCALS,DATA,APPLY,PLAN config
  class S3,DDB,IAM,SSM,CW,VPC,SG core
  class EC2 optional
  class OUT,EVD,CI,BE result
  style CONFIG fill:#ffffff,stroke:#c8d2da,color:#344653,stroke-width:1px
  style ROOT fill:#ffffff,stroke:#c8d2da,color:#344653,stroke-width:1px
  style RUN fill:#ffffff,stroke:#c8d2da,color:#344653,stroke-width:1px
  style AWS fill:#ffffff,stroke:#aebdc8,color:#344653,stroke-width:1.2px
  style CORE fill:#ffffff,stroke:#c8d6cd,color:#3d5547,stroke-width:1px
  style NET fill:#ffffff,stroke:#c8d6cd,color:#3d5547,stroke-width:1px
  style OPT fill:#ffffff,stroke:#ded6c6,color:#554c3d,stroke-width:1px
  style RESULTS fill:#ffffff,stroke:#d6cfe0,color:#3a3247,stroke-width:1px
  style BONUS fill:#ffffff,stroke:#d6cfe0,color:#3a3247,stroke-width:1px
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
