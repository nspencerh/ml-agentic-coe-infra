# Gemini Instructions - AI & Engineering Template

This document provides project-specific context and instructions for Gemini CLI when working on projects based on this AI & Engineering template repository.

## Project Context
Give project context

## Key Directories
- `src/dataops/`: Data lifecycle management (Ingest, Refine, Enrich, Publish).
- `src/mlops/`: Analytical workflows (Descriptive, Diagnostic, Predictive, Prescriptive).
- `src/devops/`: Deployment environments (Discovery, Staging, Production).
- `data/dataops/`: Local DataOps storage (Raw, Refined, Enriched, Published). **Note: `data/dataops/` is ignored by git.**
- `data/mlops/`: Local MLOps storage (Descriptive, Diagnostic, Predictive, Prescriptive).
- `notebooks/`: Exploration and prototyping.
- `tests/`: Unit and regression tests.
- `mlruns/`: MLFlow tracking directory for experiments locally.
- `config/`: Configuration files for DataOps, MLOps, and DevOps.

## Gemini Skills
When generating specific classes, utilities, or interaction modules, strictly adhere to the project's codified skills/templates stored in the `.gemini/skills/` directory.

### Core Project Skills
- **Python Development Standards** (`python-dev-standards`): Mandatory standards for Python code, dependency management (uv), linting (ruff), and testing (pytest).
- **ML & Data Pipeline Best Practices** (`ml-data-pipeline`): Workflow patterns, reproducibility (MLflow), and data artifact management.
- **DevOps & CI/CD Standards** (`devops-skill`): Infrastructure as Code (Terraform/Terragrunt) and GitHub Actions standards.
- **AI / LLM Interaction Guidelines** (`ai-llm-guidelines`): Standards for building features that interact with LLMs.

### Specialized Utility Skills
- **MLflow Tracking** (`mlflow_tracking`): Refer to this when writing code that logs parameters, models, or metrics to MLflow.
- **Snowflake Connections** (`snowflake_connector`): Refer to this when writing code that interacts with Snowflake.
- **Python CLIs** (`python_cli_fire`): Refer to this when creating command-line entry points using the `fire` library.
- **AWS CDK Patterns** (`aws_cdk_patterns`): Refer to this when creating AWS CDK infrastructure.
- **Jira Triage** (`triage-issue`): Automated Jira issue triaging and duplicate detection.
- **Spec to Backlog** (`spec-to-backlog`): Converting Confluence specs into Jira backlogs.
- **Meeting Task Capture** (`capture-tasks-from-meeting-notes`): Extracting action items from Confluence.
- **Status Reporting** (`generate-status-report`): Automated status reporting.
- **Knowledge Search** (`search-company-knowledge`): Unified search across Jira/Confluence.
- **ML Billing Analysis** (`ml-billing-analysis`): AWS cost reporting for the ML team.
- **GitHub CLI** (`gh-cli`): Integrated GitHub CLI command reference and workflows.
- **Git Commit** (`git-commit`): Standardized Git commit message generation and best practices.
- **Playwright CLI** (`playwright-cli`): Comprehensive Playwright testing workflows and automation.
- **GitHub PR Title** (`tu-gh-pr-title`): Prepares GitHub pull request titles for Transurban organization-owned repositories.
- **Python Lambda Standards** (`ml-python-lambda-standards`): MLOps/AI Engineering team's Python Lambda Runtime logging and traceback standard skills.

## Atlassian Rovo MCP

When connected to atlassian-rovo-mcp:
- **MUST** use Jira project key = BRAIN
- **MUST** use Confluence spaceId = "DSML"
- **MUST** use cloudId = "https://transurban.atlassian.net" (do NOT call getAccessibleAtlassianResources)
- **MUST** use `maxResults: 10` or `limit: 10` for ALL Jira JQL and Confluence CQL search operations.

## AWS Account Mappings
- **aws-transurban-machinelearning-datascience**: `595107320542`
- **aws-transurban-machinelearning-production**: `020569957115`
- **aws-transurban-machinelearning-staging**: `204495051184`
- **aws-transurban-root**: `776539763627`
