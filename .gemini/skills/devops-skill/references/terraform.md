## Infrastructure Deployment (DevOps)
- **Tools**: Infrastructure is managed using **Terraform** wrapped by **Terragrunt**.
- **Lambda Runtime**: Use `python3.14` for all Python-based Lambda functions.
- **Directory Structure**:
  - `src/devops/terraform/modules/`: Contains reusable Terraform modules (e.g., `serverless-api`).
  - `src/devops/terraform/live/`: Contains the live infrastructure configurations (e.g., `discovery`, `staging`, `production`).

## Data Outputs (DevOps)
Whenever the DevOps pipeline runs, it must create a subfolder for the intermediate outputs of the pipeline step as follows:
- `devops`: `data/devops/discovery`, `data/devops/staging`, `data/devops/production`
- **Timestamped Subfolder**: The pipeline must create a timestamped subfolder (format: `YYYYMMDD_HHMMSS_AEST`) within their respective output directory. The timestamp MUST be converted to Australian Eastern Standard Time (AEST) before formatting, and the `_AEST` suffix must be appended.

- **Automated Detection**: When a pipeline step runs, it must automatically detect and use the latest intermediate outputs of the previous step as input.

## State Management
- Terraform state is stored in an S3 backend: `s3://dataanalytics-discovery.ml.alpr.transurban.com/ml-fraud-genai-service/devops/terraform_states/`.
- Terragrunt automatically handles backend configuration.

## Workflow
1.  Navigate to the specific environment/component directory (e.g., `src/devops/terraform/live/discovery/serverless-api`).
2.  Authenticate with AWS (ensure valid credentials for `ap-southeast-2`).
3.  Run `terragrunt init` to initialize the directory and backend.
4.  Run `terragrunt plan` to view proposed changes.
5.  Run `terragrunt apply` to deploy changes.

## Conventions
- **Module Organization**: When adding new modules, ensure they fit into the appropriate `src/devops/` sub-directory.
- Do not modify files in `.terragrunt-cache/`.
- All new infrastructure code must be modularized in `src/devops/terraform/modules/` and instantiated in `src/devops/terraform/live/`.
