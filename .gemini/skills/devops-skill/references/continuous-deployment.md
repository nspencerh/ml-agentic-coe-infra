## Continuous Deployment (CD) Standards

### Infrastructure as Code (IaC)
- **Terraform Version**: Fixed version (e.g., `1.5.x` or latest viable) managed via `tfenv` or GitHub Actions inputs.
- **Terragrunt Version**: Fixed version matching the Terraform compatibility.
- **State Management**: Remote state in S3. Configured via `root.hcl` in Terragrunt.
- **Structure**:
    - `modules/`: Pure Terraform code. Reusable IaC modules.
    - `live/`: Terragrunt configuration (`terragrunt.hcl`) per environment (e.g., `discovery`, `staging`, `production`), which instantiates modules and passes environment-specific variables.

### AWS Environment
- **VPC**: Always put services under VPC where possible.

### Deployment Strategy
- **Blue/Green Deployment**: The DevOps pipeline must implement a blue/green deployment strategy for staging and production environments to ensure outage-free releases.

### Deployment Workflow
- **Automation**: Use GitHub Actions (or your preferred CI/CD platform) to automate testing, linting, security scanning, and deployment.
- **Least Privilege**: Ensure deployment roles and service accounts follow the principle of least privilege, granting only the permissions necessary for the deployment steps.
- **Authentication**: When deploying to cloud providers (like AWS, Azure, or GCP), use OpenID Connect (OIDC) for passwordless, secure authentication. Avoid storing long-lived static credentials.
- **Pull Requests**: Run `terragrunt plan` (or equivalent) to validate changes and show impact.
- **Main/Release Branch**: Require pull requests for infrastructure changes, utilizing `terraform plan` (or equivalent)  for review before applying changes.
- **Versioning**: Lambda functions should handle versioning hashes automatically via the Terraform `archive_file` and `source_code_hash` mechanism.

### Allowed Github Actions
The Github actions allowed in Transurban repositories must be from a repository owned by Transurban, created by GitHub, or match one of the patterns:
  - EndBug/add-and-commit@v9
  - NuGet/setup-nuget@*
  - actions-js/push@*
  - actions/setup-python@*
  - advanced-security/component-detection-dependency-submission-action@*
  - advanced-security/maven-dependency-submission-action@*
  - advanced-security/secret-scanning-review-action@*
  - atlassian/*
  - austenstone/copilot-usage@*
  - autero1/action-terragrunt@*
  - aws-actions/*
  - azure/*
  - bridgecrewio/checkov-action@*
  - changesets/action@*
  - chartboost/ruff-action@*
  - checkmarx-ts/*
  - checkmarx/*
  - checkmarx/ast-github-action@main
  - checkmarx/kics-github-action@*
  - crs-k/stale-branches@*
  - dawidd6/action-download-artifact@v3
  - docker/build-push-action@*
  - docker/setup-buildx-action@*
  - docker/setup-docker-action@*
  - docker://ghcr.io/racklet/render-drawio-action:*
  - fifsky/html-to-pdf-action@master
  - golangci/golangci-lint-action@*
  - google-github-actions/*
  - gradle/actions/dependency-submission@*
  - gradle/actions/setup-gradle@*
  - gruntwork-io/terragrunt-action@*
  - hashicorp/*
  - ietf-tools/semver-action@*
  - jfrog/setup-jfrog-cli@*
  - microsoft/*
  - mshick/add-pr-comment@*
  - nrwl/nx-set-shas@*
  - octokit/*
  - octopusdeploy/*
  - pnpm/action-setup@*
  - ruby/setup-ruby@*
  - slashmo/install-swift@main
  - snyk/actions/node@master
  - softprops/action-gh-release@*
  - sonarsource/sonarqube-scan-action@*
  - tbscompany/render-drawio-action@v1.2.2
  - the-commons-project/terragrunt-github-actions@*
  - thollander/actions-comment-pull-request@*
  - tibdex/github-app-token@*
  - transurban/github-action-templates@main
