output "reasoning_engine_ids" {
  value       = { for key, engine in google_vertex_ai_reasoning_engine.engines : key => engine.id }
  description = "Map of reasoning engine key to numeric ID"
}

output "reasoning_engine_names" {
  value       = { for key, engine in google_vertex_ai_reasoning_engine.engines : key => engine.name }
  description = "Map of reasoning engine key to full resource name"
}

output "outputs_blob_path" {
  value       = google_storage_bucket_object.reasoning_engine_register_artefact.self_link
  description = "Full GCS path to the outputs blob"
}