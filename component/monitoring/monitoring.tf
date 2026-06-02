resource "google_monitoring_notification_channel" "email_alert" {
  count        = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  display_name = var.ephemeral_suffix != null ? "Agent Support Team Email-${var.ephemeral_suffix}" : "Agent Support Team Email"
  type         = "email"
  labels = {
    email_address = var.alert_notification_email
  }
}

# 1. Agent Failure Rate
resource "google_logging_metric" "agent_errors" {
  count   = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  name    =   var.ephemeral_suffix != null ? "agent_ace/failure_count-${var.ephemeral_suffix}" : "agent_ace/failure_count"
  filter  = "jsonPayload.app_name=\"agent_ace\" AND severity=~\"ERROR|CRITICAL\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_logging_metric" "agent_invocations" {
  count   = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  name    =   var.ephemeral_suffix != null ? "agent_ace/invocation_count-${var.ephemeral_suffix}" : "agent_ace/invocation_count"
  filter  = "jsonPayload.app_name=\"agent_ace\" AND jsonPayload.event_type=\"INVOCATION_STARTING\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "agent_failure_rate" {
  count        = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  display_name = var.ephemeral_suffix != null ? "Agent ACE - High Failure Rate-${var.ephemeral_suffix}" : "Agent ACE - High Failure Rate"
  combiner     = "OR"
  severity     = "ERROR"

  depends_on = [
    google_logging_metric.agent_errors,
    google_logging_metric.agent_invocations
  ]

  conditions {
    display_name = "Failure rate > 5% over 10m"
    condition_prometheus_query_language {
      query               = "sum(rate(logging_googleapis_com:user_agent_ace_failure_count{monitored_resource=\"aiplatform.googleapis.com/ReasoningEngine\"}[10m])) / sum(rate(logging_googleapis_com:user_agent_ace_invocation_count{monitored_resource=\"aiplatform.googleapis.com/ReasoningEngine\"}[10m])) > 0.05"
      duration            = "0s"
      evaluation_interval = "60s"
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_alert.name]
}

# 2. Timeout Rate
resource "google_logging_metric" "agent_timeouts" {
  count   = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  name    = var.ephemeral_suffix != null ? "agent_ace/timeout_count-${var.ephemeral_suffix}" : "agent_ace/timeout_count"
  filter  = "jsonPayload.app_name=\"agent_ace\" AND jsonPayload.classification=\"timeout\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "agent_timeout_rate" {
  count        = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  display_name = var.ephemeral_suffix != null ? "Agent ACE - High Timeout Rate-${var.ephemeral_suffix}" : "Agent ACE - High Timeout Rate"
  combiner     = "OR"
  severity     = "ERROR"

  depends_on = [
    google_logging_metric.agent_timeouts,
    google_logging_metric.agent_invocations
  ]

  conditions {
    display_name = "Timeout rate > 5% over 10m"
    condition_prometheus_query_language {
      query               = "sum(rate(logging_googleapis_com:user_agent_ace_timeout_count{monitored_resource=\"aiplatform.googleapis.com/ReasoningEngine\"}[10m])) / sum(rate(logging_googleapis_com:user_agent_ace_invocation_count{monitored_resource=\"aiplatform.googleapis.com/ReasoningEngine\"}[10m])) > 0.05"
      duration            = "0s"
      evaluation_interval = "60s"
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_alert.name]
}

# 3. IAM / Permission Failure
resource "google_logging_metric" "agent_permission_denied" {
  count   = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  name    = var.ephemeral_suffix != null ? "agent_ace/permission_denied_count-${var.ephemeral_suffix}" : "agent_ace/permission_denied_count"
  filter  = "jsonPayload.app_name=\"agent_ace\" AND jsonPayload.classification=\"permission_denied\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "agent_permission_failure" {
  count        = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  display_name = var.ephemeral_suffix != null ? "Agent ACE - IAM/Permission Failure-${var.ephemeral_suffix}" : "Agent ACE - IAM/Permission Failure"
  combiner     = "OR"
  severity     = "CRITICAL"

  depends_on = [
    google_logging_metric.agent_permission_denied
  ]

  conditions {
    display_name = "Any permission denied error in 5m"
    condition_prometheus_query_language {
      query               = "sum(increase(logging_googleapis_com:user_agent_ace_permission_denied_count{monitored_resource=\"aiplatform.googleapis.com/ReasoningEngine\"}[5m])) > 0"
      duration            = "0s"
      evaluation_interval = "60s"
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_alert.name]
}

# 4. Model Armor Block Rate
resource "google_logging_metric" "model_armor_blocks" {
  count   = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  name    = var.ephemeral_suffix != null ? "agent_ace/model_armor_block_count-${var.ephemeral_suffix}" : "agent_ace/model_armor_block_count"
  filter  = "jsonPayload.app_name=\"agent_ace\" AND jsonPayload.classification=\"model_armor_block\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_logging_metric" "model_armor_screenings" {
  count   = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  name    = var.ephemeral_suffix != null ? "agent_ace/model_armor_screening_count-${var.ephemeral_suffix}" : "agent_ace/model_armor_screening_count"
  filter  = "jsonPayload.app_name=\"agent_ace\" AND jsonPayload.event_type=\"MODEL_ARMOR_STARTED\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "agent_model_armor_blocks" {
  count        = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  display_name = var.ephemeral_suffix != null ? "Agent ACE - Elevated Model Armor Blocks-${var.ephemeral_suffix}" : "Agent ACE - Elevated Model Armor Blocks"
  combiner     = "OR"
  severity     = "ERROR"

  depends_on = [
    google_logging_metric.model_armor_blocks,
    google_logging_metric.model_armor_screenings
  ]

  conditions {
    display_name = "Block rate > 10% over 10m"
    condition_prometheus_query_language {
      query               = "sum(rate(logging_googleapis_com:user_agent_ace_model_armor_block_count{monitored_resource=\"aiplatform.googleapis.com/ReasoningEngine\"}[10m])) / sum(rate(logging_googleapis_com:user_agent_ace_model_armor_screening_count{monitored_resource=\"aiplatform.googleapis.com/ReasoningEngine\"}[10m])) > 0.10"
      duration            = "0s"
      evaluation_interval = "60s"
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_alert.name]
}

# 5. Tool Degradation (Fallback Rate)
resource "google_logging_metric" "tool_fallbacks" {
  count   = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  name    = var.ephemeral_suffix != null ? "agent_ace/fallback_count-${var.ephemeral_suffix}" : "agent_ace/fallback_count"
  filter  = "jsonPayload.app_name=\"agent_ace\" AND jsonPayload.event_type=\"FALLBACK_TRIGGERED\" AND jsonPayload.payload.from_agent=\"InternalSearchResearcher\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_logging_metric" "tool_internal_attempts" {
  count   = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  name    = var.ephemeral_suffix != null ? "agent_ace/internal_attempt_count-${var.ephemeral_suffix}" : "agent_ace/internal_attempt_count"
  filter  = "jsonPayload.app_name=\"agent_ace\" AND jsonPayload.event_type=\"TOOL_STARTING\" AND jsonPayload.tool_name=\"InternalSearchResearcher\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "agent_tool_degradation" {
  count        = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  display_name = var.ephemeral_suffix != null ? "Agent ACE - Tool Degradation (Datastore Fallback)-${var.ephemeral_suffix}" : "Agent ACE - Tool Degradation (Datastore Fallback)"
  combiner     = "OR"
  severity     = "ERROR"

  depends_on = [
    google_logging_metric.tool_fallbacks,
    google_logging_metric.tool_internal_attempts
  ]

  conditions {
    display_name = "Fallback rate > 20% over 15m"
    condition_prometheus_query_language {
      query               = "sum(rate(logging_googleapis_com:user_agent_ace_fallback_count{monitored_resource=\"aiplatform.googleapis.com/ReasoningEngine\"}[15m])) / sum(rate(logging_googleapis_com:user_agent_ace_internal_attempt_count{monitored_resource=\"aiplatform.googleapis.com/ReasoningEngine\"}[15m])) > 0.20"
      duration            = "0s"
      evaluation_interval = "60s"
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_alert.name]
}

# 6. Model Degradation (Latency)
resource "google_logging_metric" "model_latency" {
  count   = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  name            = var.ephemeral_suffix != null ? "agent_ace/llm_latency-${var.ephemeral_suffix}" : "agent_ace/llm_latency"
  filter          = "jsonPayload.app_name=\"agent_ace\" AND jsonPayload.event_type=\"LLM_RESPONSE\" AND jsonPayload.latency_ms:*"
  value_extractor = "EXTRACT(jsonPayload.latency_ms)"

  bucket_options {
    exponential_buckets {
      num_finite_buckets = 64
      growth_factor      = 1.5
      scale              = 10
    }
  }

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "DISTRIBUTION"
    unit        = "ms"
  }
}

resource "google_monitoring_alert_policy" "agent_model_latency" {
  count        = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  display_name = var.ephemeral_suffix != null ? "Agent ACE - High Latency-${var.ephemeral_suffix}" : "Agent ACE - High Latency"
  combiner     = "OR"
  severity     = "ERROR"

  depends_on = [
    google_logging_metric.model_latency
  ]

  conditions {
    display_name = "p95 Latency > 20s over 15m"
    condition_prometheus_query_language {
      query               = "histogram_quantile(0.95, sum by (le) (rate(logging_googleapis_com:user_agent_ace_llm_latency_bucket{monitored_resource=\"aiplatform.googleapis.com/ReasoningEngine\"}[15m]))) > 20000"
      duration            = "0s"
      evaluation_interval = "60s"
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_alert.name]
}

# 7. Infrastructure Level Failures (Platform/5xx Errors)
resource "google_logging_metric" "agent_infra_errors" {
  count   = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  name    = var.ephemeral_suffix != null ? "agent_ace/infra_error_count-${var.ephemeral_suffix}" : "agent_ace/infra_error_count"
  filter  = "resource.type=\"aiplatform.googleapis.com/ReasoningEngine\" AND severity>=ERROR AND NOT jsonPayload.app_name=\"agent_ace\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "agent_infra_failure" {
  count        = ( local.deploy_discovery || local.deploy_us ) ? 1 : 0
  display_name = var.ephemeral_suffix != null ? "Agent ACE - Infrastructure Failure (Platform Error)-${var.ephemeral_suffix}" : "Agent ACE - Infrastructure Failure (Platform Error)"
  combiner     = "OR"
  severity     = "CRITICAL"

  depends_on = [
    google_logging_metric.agent_infra_errors
  ]

  conditions {
    display_name = "Platform errors > 0 over 5m"
    condition_prometheus_query_language {
      query               = "sum(increase(logging_googleapis_com:user_agent_ace_infra_error_count{monitored_resource=\"aiplatform.googleapis.com/ReasoningEngine\"}[5m])) > 0"
      duration            = "0s"
      evaluation_interval = "60s"
    }
  }

  documentation {
    content   = "The Reasoning Engine infrastructure is throwing system-level errors (e.g., HTTP 5xx responses to Gemini Enterprise, OOM crashes, or startup timeouts) before the application code can gracefully handle them. Investigate Reasoning Engine logs immediately."
    mime_type = "text/markdown"
  }

  notification_channels = [google_monitoring_notification_channel.email_alert.name]
}
