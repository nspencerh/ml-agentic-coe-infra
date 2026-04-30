# MLflow Tracking Boilerplate & Best Practices

When generating MLflow related code, please use the following patterns as a baseline.
This template originates from previous implementations in `ml-enforcement-image-quality` (v2.14) but has been updated to be compatible and robust for newer versions of MLflow (v3.4+).

## 1. Initialization Utility

Create an MLflow utility module to standardize experiment setup.

```python
import logging
import os
from typing import List, Optional

import mlflow
from mlflow.entities import Run
from mlflow.entities.experiment import Experiment

# Ideally, tracking URI should be loaded from configuration (e.g. OmegaConf)
# instead of hardcoding. Use the ARN format for SageMaker MLflow apps.
DEFAULT_TRACKING_SERVER_ARN = "TRACKING_ARN_HERE"

def init_mlflow(
    experiment_name: str,
    logger: logging.Logger,
    tracking_server_arn: str = DEFAULT_TRACKING_SERVER_ARN
) -> None:
    """
    Initializes MLflow with the given experiment name.
    For SageMaker MLflow apps, uses sagemaker.mlflow to get a presigned tracking URI.

    Args:
        experiment_name (str): Name of the experiment to track under.
        logger (logging.Logger): Logger instance.
        tracking_server_arn (str): ARN of the MLflow tracking server/app.
    """
    logger.info(f"Initializing MLflow with experiment: {experiment_name}")
    logger.info(f"Using tracking URI: {tracking_server_arn}")

    # Required for SageMaker MLflow apps
    os.environ["MLFLOW_TRACKING_URI"] = tracking_server_arn
    mlflow.set_tracking_uri(tracking_server_arn)

    # set_experiment returns an experiment object in newer versions,
    # and safely creates it if it doesn't exist.
    mlflow.set_experiment(experiment_name)


def list_experiments(
    logger: Optional[logging.Logger] = None,
    tracking_server_arn: str = DEFAULT_TRACKING_SERVER_ARN
) -> List[Experiment]:
    """
    Function to list all the experiments in MLflow.
    """
    os.environ["MLFLOW_TRACKING_URI"] = tracking_server_arn
    mlflow.set_tracking_uri(tracking_server_arn)

    experiments = mlflow.search_experiments()
    if logger is not None:
        for exp in experiments:
            logger.info(
                f"Experiment ID: {exp.experiment_id}, Name: {exp.name}, "
                f"Status: {exp.lifecycle_stage}, "
                f"Artifact Location: {exp.artifact_location}, tags: {exp.tags}"
            )
    return experiments


def list_experiment_runs(experiment_name: str, logger: Optional[logging.Logger] = None) -> List[Run]:
    """
    List all runs for a given experiment.
    """
    experiment = mlflow.get_experiment_by_name(experiment_name)
    if experiment is None:
        raise ValueError(f"Experiment '{experiment_name}' not found.")

    # Must specify output_format="list" to return a list of Run objects instead of a DataFrame
    runs = mlflow.search_runs(experiment_ids=[experiment.experiment_id], output_format="list")

    if logger:
        for run in runs:
            logger.info(
                f"Run ID: {run.info.run_id}, Name: {run.info.run_name}, Status: {run.info.status}, "
                f"Artifact Location: {run.info.artifact_uri}, Tags: {run.data.tags}"
            )
    return runs
```

## 2. Tracking a Run (Training Loop)

A standard training script pattern logging parameters, metrics, and models.

```python
import mlflow
from mlflow.models.signature import infer_signature
# from your_module import init_mlflow, get_logger

def train_model(train_params: dict, data_path: str, run_name: str):
    # init_mlflow(experiment_name='my-experiment', logger=logger)

    with mlflow.start_run(run_name=run_name):
        # 1. Log Parameters
        mlflow.log_params(train_params)
        mlflow.log_param("dataset_path", data_path)

        # 2. Train Model
        # model = ...
        # model.fit(...)

        # 3. Log Metrics
        # mlflow.log_metric("accuracy", 0.95)

        # 4. Log Model with Signature
        # IMPORTANT: Always infer and log the signature to ensure downstream inference compatibility.
        # signature = infer_signature(sample_input, sample_output)

        # mlflow.sklearn.log_model(
        #     sk_model=model,
        #     artifact_path="model",
        #     signature=signature,
        #     input_example=sample_input
        # )
```

## 3. Dataset Tracking

When working with dataframes (e.g., pandas), utilize MLflow's native dataset tracking. This traces the exact data source used during a run.

```python
import mlflow
import pandas as pd

def log_dataset(df: pd.DataFrame, s3_path: str, name: str, context: str):
    """
    Logs a dataset to the active MLflow run.
    """
    dataset = mlflow.data.from_pandas(df, source=s3_path, name=name)
    mlflow.log_input(dataset, context=context)
```

## 4. Logging Figures and Artifacts

For evaluation scripts, logging matplotlib plots directly to MLflow is an established pattern.

```python
import mlflow
import matplotlib.pyplot as plt

def evaluate_and_plot():
    # ... plotting logic ...
    # Save the current figure directly
    mlflow.log_figure(plt.gcf(), "plots/metrics/precision_recall_curve.png")
    plt.close()

    # You can also log local files as artifacts
    # mlflow.log_artifact("local_report.html", artifact_path="reports")
```

## 5. Pipeline Run Linking (Parent/Child)

When running multi-step pipelines (like SageMaker Pipelines), pass the parent run ID as a parameter to track lineage across disjoint jobs.

```python
import mlflow

def run_pipeline_step(parent_run_id: str, git_commit: str):
    with mlflow.start_run() as run:
        mlflow.log_param("MLFLOW_PARENT_RUN_ID", parent_run_id)
        mlflow.log_param("GIT_COMMIT_HASH", git_commit)
        # You can later query runs by searching for this param or tag
```

## 6. Autologging

For frameworks like XGBoost, enable autologging to automatically capture metrics, params, and the model itself, ensuring minimal boilerplate.

```python
import mlflow.xgboost

def train_xgb():
    mlflow.xgboost.autolog() # Note: Check compatibility with your xgboost version
    # Train xgboost model ...
```

## 7. Tagging Runs and Run Descriptions

Tags are essential for filtering, organizing, and discovering runs in the MLflow UI. Always add comprehensive tags to your runs.

### Essential Tags
* **`mlflow.note.content`**: Use this built-in tag to add a Markdown-formatted description to your run. This populates the "Description" field in the MLflow UI.
* **`parent_run_id`**: Explicitly link child runs to their parent (especially in multi-step pipelines) to improve traceability in the UI. (Note: MLflow also recognizes `mlflow.parentRunId` if set automatically, but adding a custom tag can help with strict queries).
* **Dataset Information**: Tag the dataset to easily trace what data trained the model.
  * `dataset_name`
  * `dataset_version`
  * `dataset_full_path`

### Other Recommended Tags
* **`environment`**: The environment where the run was executed (e.g., `dev`, `local`, currently don't expect pipeline to run in other environments).
* **`git_commit`**: The specific git commit hash of the code being executed.
* **`model_architecture`**: A high-level identifier for the model (e.g., `xgboost`, `resnet50`, `qwen2.5`).
* **`pipeline_step`**: The specific stage of the ML pipeline (e.g., `preprocessing`, `training`, `evaluation`).

```python
import mlflow

def run_with_tags(parent_run_id: str, git_commit: str, dataset_path: str):
    with mlflow.start_run() as run:
        # Standard description
        mlflow.set_tag("mlflow.note.content", "This run fine-tunes an XGBoost model on the newly cleaned dataset.")

        # Linkage
        mlflow.set_tag("parent_run_id", parent_run_id)

        # Dataset info
        mlflow.set_tag("dataset_name", "billing_images_v2")
        mlflow.set_tag("dataset_version", "v2.1")
        mlflow.set_tag("dataset_full_path", dataset_path)

        # Additional context
        mlflow.set_tag("environment", "dev")
        mlflow.set_tag("git_commit", git_commit)
        mlflow.set_tag("model_architecture", "xgboost")
        mlflow.set_tag("pipeline_step", "training")
```

## ⚠️ Migration Warnings (MLflow v2.14 to v3.x)

If migrating from older MLflow usages (like in `ml-enforcement-image-quality`), be mindful of the following:

1. **`mlflow.pyfunc.log_model` Changes**:
   - The older codebase used `mlflow.pyfunc.log_model(..., artifacts={'model_path': ...}, python_model=mlflow.pyfunc.PythonModel())`.
   - **Migration Flag**: In newer versions (v3.x), explicit path management and custom pyfunc definitions are stricter. Prefer native model flavors (e.g., `mlflow.ultralytics`, `mlflow.pytorch`, `mlflow.sklearn`) instead of wrapping everything in a raw `pyfunc` if the flavor exists. If a custom `pyfunc` is necessary, ensure your `PythonModel` correctly overrides `load_context` and `predict` with strict type hints.
2. **Model Signatures**:
   - The old codebase did not explicitly save Model Signatures.
   - **Migration Flag**: v3.x enforces stricter schema validations for model serving. **Always** generate and pass a `signature` using `infer_signature(train_X, model.predict(train_X))` when logging models.
3. **`mlflow.search_runs` Output Format**:
   - The old codebase iterated over the output of `search_runs` dynamically.
   - **Migration Flag**: By default `mlflow.search_runs()` returns a pandas DataFrame. To iterate through objects as the old code did, you must specify `output_format="list"`.
4. **`tags` Access**:
   - The old code used `run.data.tags`. This might change or require cleaner dictionary gets. Usually, `run.data.tags` works, but verify against the specific v3.4 API if properties are restructured.
5. **Autologging**:
   - The old repo explicitly turned off ultralytics autologging (`settings.update({"mlflow": False})`) to avoid conflicts.
   - **Migration Flag**: Re-evaluate if native autologging in MLflow v3.4 can handle the tracking server connection natively before writing manual `log_metrics` loops.
