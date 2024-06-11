provider "google-beta" {
  project = var.project_id
  region  = var.region
}

resource "google_pubsub_topic" "my_topic" {
  name = "my-topic"
}

output "pubsub_topic_name" {
  value = google_pubsub_topic.my_topic.name
}
