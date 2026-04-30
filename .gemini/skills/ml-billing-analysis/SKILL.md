---
name: ml-billing-analysis
description: Analyze and report AWS costs for the ML team using the billing-cost-management-mcp-server. Includes workflows for assuming the 'root-read' profile via saml2aws to access the aws-transurban-root account (776539763627) for consolidated billing data.
---

# ML Billing Analysis

## Overview
This skill provides the ML team with a standardized approach for AWS cost analysis. It focuses on using the `billing-cost-management-mcp-server` effectively, specifically for cross-account cost visibility and specialized tagging patterns.

## Authentication Workflow
To access consolidated billing data or cross-account reports, you must assume the `AWS-Transurban-Root` role in the root account.

1.  **Assume Role**: Run `saml2aws login --profile root-read`.
2.  **Verify Profile**: Ensure your AWS CLI is using the `root-read` profile (or that your environment variables are set correctly for this profile).
3.  **Root Account Details**:
    - **Account Name**: `aws-transurban-root`
    - **Account ID**: `776539763627`
    - **Role**: `AWS-Transurban-Root`

## Key ML Team Accounts
For a complete list of ML team account IDs and their purposes, see [references/accounts.md](references/accounts.md).

- **Production**: `020569957115` (AWS-Transurban-MachineLearning-Production)
- **Staging**: `204495051184` (AWS-Transurban-MachineLearning-Staging)
- **Data Science**: `595107320542` (AWS-Transurban-MachineLearning-DataScience)

## Tagging Conventions
The ML team primarily uses the `tu:project` tag for granular cost allocation.

- **Primary Project Tag**: `tu:project` (e.g., `LicencePlateRecognition / ML Platform`)
- **Legacy/Alternate Tag**: `Application` (e.g., `ALPR`, `ALPRGATEWAY`)

## Common Tasks
- **Monthly Cost Report**: Use `getCostAndUsage` with `NetAmortizedCost` for a specific account and region.
- **Project-Level Breakdown**: Group by the `tu:project` tag to see spend across different ML initiatives.
- **Anomalies**: Use `getAnomalies` in the production account to identify unexpected spend.
