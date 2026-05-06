gemini_app = {
  engine_id      = "gemini-chat"
  display_name   = "test-gemini-enterprise-iac"
  location       = "us"
  data_store_ids = []
}

reasoning_engines = {
  "support-agent" = {
    display_name = "Support Agent"
    description  = "Customer support reasoning engine"
  }
  "research-agent" = {
    display_name = "Research Agent"
    description  = "Internal research reasoning engine"
  }
}

reasoning_engine_artefact_bucket_name = "tu-agentspace-pp-2"
