output "engine_id" {
  value       = google_discovery_engine_chat_engine.this.engine_id
  description = "The Discovery Engine app ID"
}

output "name" {
  value       = google_discovery_engine_chat_engine.this.name
  description = "Full resource name of the Discovery Engine app"
}