# resource "google_bigquery_dataset" "deployments" {
#   dataset_id = "agent_platform_deployments"
#   location   = var.location

#   description = "Deployment event tracking for Gemini Enterprise agents."

#   labels = {
#     environment = var.environment
#     managed_by  = "terraform"
#   }
# }

# resource "google_bigquery_table" "deployment_events" {
#   dataset_id          = google_bigquery_dataset.deployments.dataset_id
#   table_id            = "deployment_events"
#   deletion_protection = true

#   description = "Append-only log of deployment lifecycle events."

#   schema = jsonencode([
#     { name = "event_id", type = "STRING", mode = "REQUIRED", description = "UUID, unique per row" },
#     { name = "deployment_id", type = "STRING", mode = "REQUIRED", description = "GHA run_id, groups rows for one deployment" },
#     { name = "component", type = "STRING", mode = "REQUIRED", description = "Component name (e.g. gemini)" },
#     { name = "environment", type = "STRING", mode = "REQUIRED", description = "Target environment (staging, production)" },
#     { name = "commit_sha", type = "STRING", mode = "REQUIRED", description = "Git SHA of the deployed commit" },
#     { name = "status", type = "STRING", mode = "REQUIRED", description = "commenced, deployed, succeeded, or failed" },
#     { name = "timestamp", type = "TIMESTAMP", mode = "REQUIRED", description = "Event timestamp" },
#     { name = "reasoning_engine_ids", type = "JSON", mode = "NULLABLE", description = "Map of agent-key to numeric RE ID" },
#     { name = "engine_id", type = "STRING", mode = "REQUIRED", description = "Discovery Engine app ID" },
#     { name = "package_uri", type = "STRING", mode = "NULLABLE", description = "GCS URI of agent package tarball" },
#     { name = "container_image", type = "STRING", mode = "NULLABLE", description = "Container image URI with digest or tag" },
#     { name = "gha_run_url", type = "STRING", mode = "REQUIRED", description = "GitHub Actions run URL" },
#     { name = "failure_reason", type = "STRING", mode = "NULLABLE", description = "Reason for failure, null unless status is failed" },
#   ])
# }

# resource "google_bigquery_table" "eval_runs" {
#   dataset_id          = google_bigquery_dataset.deployments.dataset_id
#   table_id            = "eval_runs"
#   deletion_protection = true

#   description = "One row per evaluation run."

#   schema = jsonencode([
#     { name = "eval_id", type = "STRING", mode = "REQUIRED", description = "UUID" },
#     { name = "deployment_id", type = "STRING", mode = "REQUIRED", description = "FK to deployment_events.deployment_id" },
#     { name = "trigger", type = "STRING", mode = "REQUIRED", description = "deployment or scheduled" },
#     { name = "timestamp", type = "TIMESTAMP", mode = "REQUIRED", description = "Eval run timestamp" },
#     { name = "passed", type = "BOOL", mode = "REQUIRED", description = "Whether the eval passed" },
#     { name = "score", type = "FLOAT64", mode = "NULLABLE", description = "Aggregate score 0-1" },
#     { name = "agent_name", type = "STRING", mode = "REQUIRED", description = "Agent directory name" },
#     { name = "reasoning_engine_id", type = "STRING", mode = "REQUIRED", description = "Reasoning Engine numeric ID" },
#     { name = "eval_details", type = "JSON", mode = "NULLABLE", description = "Per-question results" },
#   ])
# }

# resource "google_bigquery_table" "deployment_events_latest" {
#   dataset_id          = google_bigquery_dataset.deployments.dataset_id
#   table_id            = "deployment_events_latest"
#   deletion_protection = false

#   description = "View: most recent event per deployment_id."

#   view {
#     query = <<-SQL
#       SELECT *
#       FROM `${var.project_id}.${google_bigquery_dataset.deployments.dataset_id}.deployment_events`
#       QUALIFY ROW_NUMBER() OVER (PARTITION BY deployment_id ORDER BY timestamp DESC) = 1
#     SQL

#     use_legacy_sql = false
#   }

#   depends_on = [google_bigquery_table.deployment_events]
# }
