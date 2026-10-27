# Architecture

Each environment is configured with its own file under `envs/`. The same Terraform root creates resources in the selected AWS region; optional services are controlled by variables in the selected file.

```mermaid
%%{init: {"theme": "base", "themeVariables": {"edgeLabelBackground": "#f5f2eb"}, "flowchart": {"curve": "linear", "nodeSpacing": 32, "rankSpacing": 48}}}%%
flowchart LR
  ENV["Environment tfvars<br/>dev · staging · prod"]
  TF["Terraform root<br/>AWS provider · names · tags"]
  ENV --> TF

  subgraph AWS["AWS account · selected region"]
    direction TB

    subgraph CORE["Core resources"]
      direction LR
      S3["Private S3 bucket"]
      VPC["Default VPC"] --> SG["Security group"]
    end

    subgraph OPTIONAL["Feature-flagged services"]
      direction LR
      IAM["IAM role + policy"]
      DDB["DynamoDB"]
      SSM["SSM parameters"]
      CW["CloudWatch logs"]
      EC2["EC2 test instance"]
    end

    IAM -. scoped access .-> S3
    IAM -. parameter reads .-> SSM
    SG -->|attached to| EC2
  end

  TF --> CORE
  TF -. optional settings .-> OPTIONAL

  classDef config fill:#eef3f8,stroke:#8497a8,color:#263746
  classDef core fill:#edf4ef,stroke:#91a99a,color:#294337
  classDef optional fill:#f5f2eb,stroke:#b2a488,color:#443e32
  class ENV,TF config
  class S3,VPC,SG core
  class IAM,DDB,SSM,CW,EC2 optional
  style AWS fill:#fbfcfd,stroke:#b8c5ce,color:#344653
  style CORE fill:#f7faf8,stroke:#c8d6cd,color:#3d5547
  style OPTIONAL fill:#fcfaf6,stroke:#ded6c6,color:#554c3d
```

The bucket is private. SSH is closed unless CIDRs are supplied. The IAM policy is scoped to the bucket and SSM parameters; the role has an EC2 trust policy but is not attached to the test instance. DynamoDB uses on-demand billing, SSM values are standard-tier strings, and log retention is configured per environment.

The supplied environment files enable DynamoDB, IAM, SSM, and CloudWatch logs. S3 versioning is off in dev and on in staging and prod; lifecycle expiration is enabled in all three. EC2 is off in every supplied environment and is restricted to dev with explicit approval.

This is a configuration-only project; no AWS resources have been applied. No Terraform modules are used. Resource names are assembled in `locals.tf` from company, project, environment, resource type, and region.
