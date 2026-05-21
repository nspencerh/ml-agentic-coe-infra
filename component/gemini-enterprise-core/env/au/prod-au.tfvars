gemini_app = {
  engine_id      = "gemini-chat"
  display_name   = "test-gemini-enterprise-iac"
  location       = "au"
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

registry_bucket = "tu-agentspace-pr-2"
