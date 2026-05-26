# Gemini Enterprise Foundations

This repository contains the foundational Terraform infrastructure for deploying Gemini Enterprise solutions on Google Cloud Platform. It provisions [Discovery Engine](https://cloud.google.com/generative-ai-app-builder/docs/introduction) apps and [Vertex AI Agent Platform (Reasoning Engine)](https://cloud.google.com/vertex-ai/docs/agent-builder/introduction) shells.

This repository is designed to be used in tandem with a separate `gemini-agents` monorepo, which handles agent code deployment and registration. The two repositories are decoupled via a GCS outputs blob that this repository writes after each apply.

## Architecture

The repository is structured into reusable Terraform `modules` and deployable `components`.

*   `modules/discovery-engine`: Provisions a `google_discovery_engine_chat_engine`.
*   `modules/reasoning-engines`: Provisions multiple `google_vertex_ai_reasoning_engine` resources and writes their IDs to a GCS blob for consumption by downstream CI/CD.
*   `component/gemini`: A deployable unit that combines the `discovery-engine` and `reasoning-engines` modules to provision a complete agent environment.
*   `component/monitoring`: Provisions BigQuery tables for tracking deployment and evaluation events.

### CI/CD

The CI/CD process is managed by GitHub Actions and is designed around a promotion pipeline:

`PR open` -> `Ephemeral Environment Apply` -> `PR close` -> `Ephemeral Environment Destroy`

`Merge to main` -> `dev` -> `staging` (approval gate) -> `production` (approval gate)

Deployment and evaluation history is logged to BigQuery tables provisioned by the `monitoring` component.

## Prerequisites

Before you can deploy resources using this repository, you will need:

1.  **GCP Project(s)**: Separate projects for `dev`, `staging`, and `production` environments are recommended.
2.  **GCS Bucket for Terraform State**: A GCS bucket to store Terraform state files.
3.  **GCS Bucket for Outputs**: A GCS bucket to store the JSON outputs blob. This can be the same as the state bucket.
4.  **Workload Identity Federation**: Configured in each GCP project to allow GitHub Actions to authenticate with Google Cloud without service account keys.
5.  **GitHub Environments**: `dev`, `staging`, and `production` environments configured in GitHub with appropriate protection rules and approvers.

## Usage

### Components

#### `gemini`

This component deploys a Discovery Engine app and a set of Reasoning Engine shells. Configuration is managed via `.tfvars` files for each environment.

Example `staging.tfvars`:
```terraform
gemini_app = {
  engine_id      = "my-gemini-app-staging"
  display_name   = "My Gemini App (Staging)"
  data_store_ids = ["my-data-store_12345"]
}

reasoning_engines = {
  "customer-service-agent" = {
    display_name = "Customer Service Agent"
  },
  "internal-helpdesk-agent" = {
    display_name = "Internal Helpdesk Agent"
  }
}
```

#### `monitoring`

This component deploys the BigQuery dataset and tables required for CI/CD logging. It should be deployed once to a central monitoring or staging project.

### Deployment

Deployments are handled automatically by the GitHub Actions workflows on pull requests and merges to the `main` branch.
