---
name: ml-python-lambda-standards
description: Generalized standards for Python Lambda functions in MLOps/AI Engineering projects. Use when creating or updating Lambda functions to ensure consistent logging and error handling with MLOps/AI Engineering team's log dimensions and error codes.
---

# ML Python Lambda Standards

This skill provides the standard logging and error handling patterns for the ML team's Python Lambda functions. These standards are designed to be general and should be customized with project-specific values.

## Logging Standards

All Lambda functions must use a project-specific logger with a standardized format that includes `aws_request_id` and customizable log dimensions.

- **Setup**: Use the pattern in `references/logging_setup.py`.
- **Project Name**: Replace `<PROJECT_NAME>` with the actual project name (e.g., `alpr-pipeline`).
- **Log Dimensions**: Define project-specific dimensions (e.g., `client_id`, `asset_id`, `model_version`) in the `LOG_DIMENSIONS` list.
- **Format**: The log format is dynamically constructed as `%(aws_request_id)s|%(asctime)s|<PROJECT_NAME>|<DIMENSIONS>|%(levelname)s|%(message)s`.
- **Context**: Always pass `extra=log_params` to logging calls.
- **Initialization**: Update `log_params` at the start of the `lambda_handler` using the context and any project-specific dimensions.

## Error Handling Standards

Wrap the main logic of `lambda_handler` in a `try...except Exception` block. Error codes must be determined based on the actual error type and the specific definitions of each project.

- **Pattern**: See `references/error_handling.py`.
- **Log Format**: `logger.error("%s - %s - %s", error_code, e.__class__.__name__, str(e), extra=log_params)`
- **Error Codes**: Use project-specific error codes (e.g., 550, 400, 500) based on exception mapping. Implement `get_error_code(e)` for this purpose.
- **Traceback**: Log the traceback as a single-line string for better log aggregation.
- **Re-raise**: Always `raise e` at the end of the exception block.

## Key Resources

- `references/logging_setup.py`: Boilerplate for logger initialization with dynamic dimension support.
- `references/error_handling.py`: Boilerplate for the standard `try...except` block with error code mapping guidance.
