"""Lambda logging standardization references."""

import logging
import os
import sys

# Replace <PROJECT_NAME> with the actual project name (e.g., 'alpr-pipeline')
PROJECT_NAME = "<PROJECT_NAME>"
# List project-specific log dimensions (e.g., ["client_id", "asset_id"])
LOG_DIMENSIONS = ["<DIMENSION_1>", "<DIMENSION_2>"]
LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO")

logger = logging.getLogger(PROJECT_NAME)
logger.setLevel(logging.getLevelName(LOG_LEVEL))
logger.propagate = False

# Construct formatter string dynamically based on dimensions
dimension_format = "|".join([f"%({d})s" for d in LOG_DIMENSIONS])
log_format = (
    f"%(aws_request_id)s|%(asctime)s|{PROJECT_NAME}|"
    f"{dimension_format}|%(levelname)s|%(message)s"
)

console_handler = logging.StreamHandler(stream=sys.stdout)
console_handler.setFormatter(
    logging.Formatter(
        log_format,
        datefmt="%Y-%m-%dT%H:%M:%S",
    )
)
logger.addHandler(console_handler)

# Initial log parameters
log_params = {"aws_request_id": "na"}
for d in LOG_DIMENSIONS:
    log_params[d] = "na"


def update_log_params(context, **kwargs):
    """Update global log_params with context and additional dimensions."""
    global log_params
    log_params["aws_request_id"] = getattr(context, "aws_request_id", "na")
    for key, value in kwargs.items():
        if key in LOG_DIMENSIONS:
            log_params[key] = value
