environment = "dev"

gemini_app = {
  engine_id      = "gemini-chat-dev"
  display_name   = "Gemini Chat Dev"
  location       = "us"
  data_store_ids = ["default-data-store"]
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