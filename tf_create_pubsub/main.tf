provider "google-beta" {
  project = var.project_id
  region  = var.region
}

resource "google_pubsub_topic" "my_topic" {
  name = "station-status"
  message_retention_duration = "86600s"
}

output "pubsub_topic_name" {
  value = google_pubsub_topic.my_topic.name
}
