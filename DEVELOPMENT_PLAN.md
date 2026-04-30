# Development Plan: Gemini Enterprise Foundations

## Overview

This repo provisions Gemini Enterprise (Discovery Engine) apps and Vertex AI Agent Platform (Reasoning Engine) shells on GCP via Terraform modules. A companion agent monorepo pattern handles agent code deployment and Gemini Enterprise registration via CI/CD. The two repos are decoupled by a GCS outputs blob written by Terraform after each apply, which carries resource IDs into the agent pipeline without requiring manual variable management.

## Requirements

### Functional Requirements

- FR-001: A `modules/discovery-engine/` module creates a single `google_discovery_engine_chat_engine` resource and exposes its ID and full resource name as outputs.
- FR-002: A `modules/reasoning-engines/` module accepts a map of reasoning engine configs, creates all `google_vertex_ai_reasoning_engine` resources, and writes a JSON blob to GCS at a standard path keyed by component and environment.
- FR-003: A `modules/agent-registration/` module registers Reasoning Engines as assistants on a Discovery Engine app via `google_discovery_engine_assistant` (google-beta provider, as this resource is not yet in GA).
- FR-004: The `component/gemini/` component calls all three modules, supports one Discovery Engine app and multiple Reasoning Engines per environment, and exposes outputs for CI/CD consumption.
- FR-005: A `component/monitoring/` component provisions BigQuery tables `deployment_events` and `eval_runs`, plus a `deployment_events_latest` view. It deploys to the staging GCP project initially.
- FR-005: The foundations repo has four GHA workflows: `terraform-plan.yml` (PR plan), `terraform-pr-environment.yml` (ephemeral PR env apply/destroy), `terraform-deploy.yml` (promotion pipeline), and `evaluate-scheduled.yml` (weekly production eval).
- FR-006: `terraform-deploy.yml` deploys sequentially: dev (auto) -> staging (engineer approval gate) -> staging eval -> production (admin approval gate) -> post-prod eval. Failed apply or eval writes a `failed` event row and does not proceed.
- FR-007: `terraform-deploy.yml` triggers a rollback on post-production eval failure by querying BigQuery for the last `succeeded` deployment event and redeploying using the stored `package_uri` or `container_image` from that event.
- FR-008: `evaluate-scheduled.yml` runs weekly against production, writes results to `eval_runs` with `trigger=scheduled`, and opens a GitHub issue on failure. It never triggers rollback.
- FR-009: Every deployment writes append-only rows to `deployment_events` with status: `commenced` (before apply), `deployed` (after successful apply, includes artifact metadata), `succeeded` (after eval passes), or `failed` (on apply or eval failure). Each row has a unique `event_id`; rows for the same deployment share a `deployment_id` (GHA run_id).
- FR-010: The agent monorepo scaffold (under `docs/agent-monorepo/`) has a single auto-discovering `deploy.yml` that reads GCS outputs blobs across all components via wildcard path, detects changed agent directories via path filtering, and runs `agents-cli deploy + publish` per changed agent.
- FR-011: A `new-agent.yml` workflow_dispatch workflow in the agent repo scaffolds a new agent directory, opens a PR in the agent repo, and opens a PR in the foundations repo adding the new reasoning engine to the tfvars. It is callable via the GitHub REST API dispatch endpoint.
- FR-012: `outputs_bucket` is a global variable shared across all components via `variables/globals.tf`. Each component writes its GCS blob to `outputs/{component}/{environment}/gemini-outputs.json`.

### Non-Functional Requirements

- NFR-001: Terraform modules follow HashiCorp style conventions (snake_case, no hardcoded values, all variables typed with descriptions).
- NFR-002: The Reasoning Engine `spec` block is optional - the module creates a valid resource shell without it, supporting teams that deploy agent code separately.
- NFR-003: GCS outputs blob is written as a `google_storage_bucket_object` resource, not via `local-exec`. Both modules use the GA `hashicorp/google` provider (>= 7.30) - `google_vertex_ai_reasoning_engine` landed in GA as of v7.30.
- NFR-004: No SA keys used anywhere - Workload Identity Federation for GHA, Application Default Credentials for local runs.
- NFR-005: All GHA action versions are pinned.
- NFR-006: Branch isolation comes from GCP project boundaries - feature branches deploy to a separate ephemeral project, not to staging or production.
- NFR-007: The weekly scheduled eval and deployment-triggered rollback are structurally separate workflows. A scheduled eval failure can never trigger a rollback.

### Out of Scope

- Provisioning the GCS state bucket or outputs bucket (prerequisites, provided via variables).
- IAM configuration for the Terraform SA or Workload Identity pool.
- Agent Python code - the agent monorepo templates are scaffold only.
- A2A (Agent-to-Agent) registration mode.
- The Gemini Enterprise app or GitHub integration that calls `new-agent.yml` via the dispatch API.

## Architecture

```
gemini-enterprise-foundations (this repo)
  variables/
    globals.tf              <- shared vars incl. outputs_bucket
  modules/
    discovery-engine/       <- one DE chat app
    reasoning-engines/      <- N reasoning engine shells + GCS outputs blob
    agent-registration/     <- links reasoning engines to DE app as assistants
  component/
    gemini/                 <- one DE app + N reasoning engines per env
    monitoring/             <- BigQuery deployment_events, eval_runs tables
  .github/workflows/
    terraform-plan.yml
    terraform-pr-environment.yml
    terraform-deploy.yml
    evaluate-scheduled.yml

      |
      | writes gs://{outputs_bucket}/outputs/{component}/{env}/gemini-outputs.json
      v

gemini-agents (separate repo - scaffold in docs/agent-monorepo/)
  agents/
    agent-one/
    agent-two/
  .github/workflows/
    ci.yml                  <- pytest on PR for changed agents
    deploy.yml              <- auto-discover agents, read GCS blobs, deploy+publish
    new-agent.yml           <- workflow_dispatch: scaffold + open foundations PR
  scripts/
    add-reasoning-engine.py <- appends RE entry to foundations tfvars, opens PR
    bq-log-deployment.py    <- log-event and query-last-success commands
    bq-log-eval.py          <- write eval results to BigQuery
  Makefile
```

### GCS Outputs Blob Schema

```json
{
  "engine_id": "my-chat-app",
  "project_id": "my-project",
  "location": "us-central1",
  "reasoning_engines": {
    "agent-one": {
      "id": "123456",
      "name": "projects/my-project/locations/us-central1/reasoningEngines/123456",
      "display_name": "My First Agent"
    },
    "agent-two": {
      "id": "789012",
      "name": "projects/my-project/locations/us-central1/reasoningEngines/789012",
      "display_name": "My Second Agent"
    }
  }
}
```

### BigQuery Schema

**`deployment_events`** (append-only event log):

| Column | Type | Notes |
|--------|------|-------|
| event_id | STRING | UUID, unique per row |
| deployment_id | STRING | GHA run_id - groups rows for one deployment |
| component | STRING | e.g. "gemini" |
| environment | STRING | "staging" or "production" |
| commit_sha | STRING | Git SHA of the deployed commit |
| status | STRING | "commenced", "deployed", "succeeded", "failed" |
| timestamp | TIMESTAMP | |
| reasoning_engine_ids | JSON | map of agent-key to numeric RE ID, populated from "deployed" onwards |
| engine_id | STRING | Discovery Engine app ID |
| package_uri | STRING | GCS URI of agent package tarball (Agent Runtime deploys), nullable |
| container_image | STRING | Container image URI with digest or tag (Cloud Run/GKE deploys), nullable |
| gha_run_url | STRING | |
| failure_reason | STRING | null unless failed |

**`eval_runs`** (one row per eval run):

| Column | Type | Notes |
|--------|------|-------|
| eval_id | STRING | UUID |
| deployment_id | STRING | FK to deployment_events.deployment_id |
| trigger | STRING | "deployment" or "scheduled" |
| timestamp | TIMESTAMP | |
| passed | BOOL | |
| score | FLOAT64 | aggregate score 0-1 |
| agent_name | STRING | |
| reasoning_engine_id | STRING | |
| eval_details | JSON | per-question results |

**`deployment_events_latest`** view: most recent row per `deployment_id` using `QUALIFY ROW_NUMBER() OVER (PARTITION BY deployment_id ORDER BY timestamp DESC) = 1`.

### Deployment Pipeline

```
PR open   -> ephemeral apply (auto, namespaced by PR number)
PR close  -> ephemeral destroy (auto)

Merge to main:
  -> dev apply (auto)
       log: commenced -> deployed / failed
  -> [engineers team approval]
  -> staging apply
       log: commenced -> deployed / failed
  -> staging eval
       log: succeeded / failed
  -> [admins team approval]
  -> prod apply
       log: commenced -> deployed / failed
  -> post-prod eval
       log: succeeded / failed
       -> fail: query BQ for last succeeded deployment, rollback using package_uri/container_image

Weekly (scheduled):
  -> prod eval
       write to eval_runs (trigger=scheduled)
       -> fail: open GitHub issue (NO rollback)
```

### Environment Isolation

| Environment | GCP Project | Trigger | Gate |
|-------------|-------------|---------|------|
| Ephemeral | Shared non-prod | PR open/sync | None |
| Dev | Non-prod | Merge to main | None |
| Staging | Staging | After dev | Engineers team approval |
| Production | Production | After staging eval | Admins team approval |
| Monitoring | Staging (temporary) | Separate apply | Manual |

Branch isolation is at the GCP project boundary - feature branches cannot reach staging or production regardless of workflow configuration.

## Implementation Phases

### Phase 1: Terraform Modules

**Goal:** Both modules complete and validated.

#### Tasks

- [x] `modules/discovery-engine/variables.tf` - project_id, engine_id, display_name, location, collection_id, data_store_ids, industry_vertical, default_language_code, time_zone, company_name
- [x] `modules/discovery-engine/main.tf` - `google_discovery_engine_chat_engine` resource
- [x] `modules/discovery-engine/outputs.tf` - engine_id, name
- [x] `modules/discovery-engine/versions.tf` - hashicorp/google >= 7.30
- [x] `modules/reasoning-engines/variables.tf` - project_id, region, reasoning_engines map (with optional package_spec per engine), engine_id, outputs_bucket, outputs_component, outputs_environment
- [x] `modules/reasoning-engines/main.tf` - `google_vertex_ai_reasoning_engine` for_each with dynamic spec block, `google_storage_bucket_object` for GCS outputs blob
- [x] `modules/reasoning-engines/outputs.tf` - reasoning_engine_ids map, reasoning_engine_names map, outputs_blob_path
- [x] `modules/reasoning-engines/versions.tf` - hashicorp/google >= 7.30

#### Acceptance Criteria

- [x] `terraform validate` passes in both module directories
- [x] Optional `package_spec` omits the spec block entirely when not provided (dynamic block)
- [x] GCS blob content matches documented schema
- [x] All variables have type constraints and descriptions

### Phase 2: Gemini Component

**Goal:** Component uses modules, old inline resources removed, outputs exposed.

#### Tasks

- [ ] Replace `discoveryengine.tf` with a `module "discovery_engine"` call
- [ ] Replace `reasoningengine.tf` with a `module "reasoning_engines"` call
- [ ] Add `outputs.tf` exposing engine_id, reasoning_engine_ids, reasoning_engine_names, project_id, location
- [ ] Update `variables.tf` - remove agent_registrations, add outputs_bucket and outputs_component
- [ ] Add `outputs_bucket` to `variables/globals.tf` and `variables/default.tfvars`
- [ ] Update `dev.tfvars` with one app and two agents as a realistic example

#### Acceptance Criteria

- [ ] `terraform validate` passes
- [ ] `agent_registrations` variable removed
- [ ] No inline `google_discovery_engine_chat_engine` or `google_vertex_ai_reasoning_engine` resources remain in the component

### Phase 3: Monitoring Component

**Goal:** BigQuery tables and view provisioned by Terraform, targeting the staging project.

#### Tasks

- [ ] `component/monitoring/src/artifacts.tf` - provider config, GCS backend
- [ ] `component/monitoring/src/globals.tf` - shared variables
- [ ] `component/monitoring/src/variables.tf` - bq_dataset_id, bq_location
- [ ] `component/monitoring/src/bigquery.tf` - `google_bigquery_dataset`, `google_bigquery_table` for deployment_events (with commit_sha, package_uri, container_image columns), `google_bigquery_table` for eval_runs, `google_bigquery_table` for deployment_events_latest view
- [ ] `component/monitoring/staging.tfvars` - uses staging project_id
- [ ] `component/monitoring/src/Makefile`

#### Acceptance Criteria

- [ ] `terraform validate` passes
- [ ] deployment_events table schema includes commit_sha, package_uri, container_image as nullable STRING columns
- [ ] View SQL correctly identifies most recent row per deployment_id
- [ ] All table schemas match documented columns and types

### Phase 4: GitHub Actions - Foundations Repo

**Goal:** Four workflows covering all deployment and evaluation scenarios.

#### Tasks

- [ ] `terraform-plan.yml` - on PR: init, plan, post plan output as PR comment
- [ ] `terraform-pr-environment.yml` - on PR open/sync: apply with state prefix `gemini/pr-{number}`; on PR close: destroy
- [ ] `terraform-deploy.yml` - on push to main: dev (auto) -> staging gate (engineers) -> staging eval -> prod gate (admins) -> post-prod eval -> rollback job on eval failure; logs deployment_events rows at each stage
- [ ] `evaluate-scheduled.yml` - weekly cron: eval production, write to eval_runs (trigger=scheduled), open GitHub issue on failure, no rollback job
- [ ] Document required GitHub Environments and reviewers in README

#### Acceptance Criteria

- [ ] Feature branch commits cannot reach staging or production (trigger: `push branches: [main]`)
- [ ] Staging GitHub Environment has `engineers` team as required reviewer
- [ ] Production GitHub Environment has `admins` team as required reviewer
- [ ] Post-prod eval failure triggers rollback job only within terraform-deploy.yml
- [ ] evaluate-scheduled.yml has no rollback job
- [ ] All action versions pinned

### Phase 5: Agent Monorepo Scaffold

**Goal:** Complete reference implementation under `docs/agent-monorepo/` for teams to copy into a new repo.

#### Tasks

- [ ] `docs/agent-monorepo/.github/workflows/ci.yml` - pytest on PR for changed agent dirs only
- [ ] `docs/agent-monorepo/.github/workflows/deploy.yml` - discover agents via directory scan, read all GCS blobs via `gsutil ls` wildcard, matrix deploy+publish for changed agents, same promotion pattern (dev -> staging gate -> prod gate)
- [ ] `docs/agent-monorepo/.github/workflows/new-agent.yml` - workflow_dispatch inputs: agent_name, display_name, environment; creates agent scaffold, opens agent repo PR, opens foundations repo PR via FOUNDATIONS_REPO_TOKEN
- [ ] `docs/agent-monorepo/scripts/add-reasoning-engine.py` - appends reasoning engine entry to the specified foundations tfvars file
- [ ] `docs/agent-monorepo/scripts/bq-log-deployment.py` - `log-event` subcommand (writes event row with status, artifact metadata), `query-last-success` subcommand (returns commit_sha, package_uri, container_image for rollback)
- [ ] `docs/agent-monorepo/scripts/bq-log-eval.py` - writes a row to eval_runs, accepts `--trigger deployment|scheduled`
- [ ] `docs/agent-monorepo/Makefile` - `new-agent` target as local convenience wrapper calling `gh workflow run new-agent.yml`
- [ ] `docs/agent-monorepo/agents/example-agent/` - minimal working scaffold (agents/__init__.py, root_agent.py, tests/, pyproject.toml, .env.example)

#### Acceptance Criteria

- [ ] `deploy.yml` resolves reasoning engine IDs from GCS blob without any hardcoded per-agent variables
- [ ] Path filter skips unchanged agents
- [ ] `new-agent.yml` is callable via `POST /repos/{owner}/{repo}/actions/workflows/new-agent.yml/dispatches`
- [ ] `bq-log-eval.py --trigger scheduled` writes correct trigger value and contains no rollback logic
- [ ] `bq-log-deployment.py query-last-success` returns the most recent row with status "succeeded"

### Phase 6: Documentation

**Goal:** README and SDLC diagram are the single source of truth for the full workflow.

#### Tasks

- [ ] `docs/sdlc.md` - Mermaid flowchart: PR ephemeral envs, promotion pipeline with approval gates, post-prod eval and rollback, weekly scheduled eval, new-agent dispatch flow
- [ ] Update `README.md` - overview, architecture diagram, prerequisites, component usage (gemini + monitoring), CI/CD variable reference table, GitHub Environments setup, agent monorepo setup guide

#### Acceptance Criteria

- [ ] CI/CD variable reference table maps foundations Terraform outputs to agent repo variable names
- [ ] GitHub Environments setup section lists exactly which environments to create, with which teams as reviewers
- [ ] No placeholder text remaining in README

## QA Checklist

- [ ] `terraform validate` passes for both modules, gemini component, and monitoring component
- [ ] `terraform plan` with `dev.tfvars` produces the correct resource types and count
- [ ] GCS outputs blob JSON matches documented schema
- [ ] `deployment_events_latest` view returns exactly one row per deployment_id
- [ ] `bq-log-deployment.py log-event` writes correct status values for each lifecycle stage
- [ ] `bq-log-deployment.py query-last-success` returns the most recent succeeded deployment including artifact fields
- [ ] `new-agent.yml` dispatch opens PRs in both agent and foundations repos
- [ ] No hardcoded project IDs, bucket names, or credentials anywhere
- [ ] All GHA action versions pinned

## Dependencies and Prerequisites

- GCS bucket for Terraform state per GCP project (provided via `TF_STATE_BUCKET`)
- GCS bucket for outputs blob (provided via `outputs_bucket`, can be the same bucket as state)
- Workload Identity Federation configured in each GCP project for GHA auth
- `FOUNDATIONS_REPO_TOKEN` secret in agent repo (GitHub PAT or App token with PR write on foundations repo)
- `agents-cli` available on GHA runners in the agent repo
- Google provider >= 7.30, Terraform >= 1.9, Python >= 3.11
