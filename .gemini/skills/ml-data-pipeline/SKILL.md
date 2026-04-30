---
name: ml-data-pipeline
description: Best practices for ML and Data pipelines, separation of logic, reproducibility, and structured data outputs. Use when designing or implementing data pipelines, ML experiments, or data processing workflows.
---

# ML and Data Pipeline Best Practices

This skill provides mandatory standards for ML and Data pipeline development in this project.

## Pipeline Workflow Best Practices
Projects based on this template typically follow a structured pipeline pattern:
1.  **Orchestration**: Python scripts act as entry points for different pipeline stages.
2.  **Logic Separation**: Core logic is encapsulated in modular Python classes.
3.  **Reproducibility**: Ensure all pipeline steps are fully reproducible. Use MLflow or similar tools to track parameters, metrics, and models.

## Data Outputs and Artifacts
- Structure intermediate outputs logically (e.g., separating raw, refined, and enriched data).
- For pipeline runs, it is recommended to create timestamped subfolders (e.g., `YYYYMMDD_HHMMSS`) to version outputs and prevent overwriting previous runs.
- **Avoid hard-coding file paths**: All paths and environment-specific parameters must be defined in domain-specific configuration files (e.g., in the `config/` directory).
