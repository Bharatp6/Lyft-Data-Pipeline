provider "google-beta" {
  project = var.project_id
  region  = var.region
}

resource "google_pubsub_topic" "station-status" {
  name = "station-status"
  message_retention_duration = "86600s"
}

