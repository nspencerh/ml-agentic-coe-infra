"""Lambda error handling standardization references."""

import logging
import traceback

# Replace <PROJECT_NAME> with the actual project name
logger = logging.getLogger("<PROJECT_NAME>")
# Initialize log_params with aws_request_id and other required dimensions
log_params = {"aws_request_id": "na"}
# Add project-specific dimensions as needed
# for d in LOG_DIMENSIONS: log_params[d] = "na"


def get_error_code(exception):
    """Return a project-specific error code based on the exception type.

    This should be implemented according to the project's error definition.
    """
    # Example mapping:
    # if isinstance(exception, ValueError): return 400
    # return 500
    return "<ERROR_CODE>"


def lambda_handler(event, context):
    """Handle Lambda invocations."""
    try:
        # Standard first step: update log parameters
        # update_log_params(context)

        # Business logic goes here
        pass
    except Exception as e:
        error_code = get_error_code(e)
        # Standard error logging format for ML team
        logger.error(
            "%s - %s - %s", error_code, e.__class__.__name__, str(e), extra=log_params
        )
        logger.info(
            {"Traceback": "".join(traceback.format_exc().split("\n"))}, extra=log_params
        )
        raise e
