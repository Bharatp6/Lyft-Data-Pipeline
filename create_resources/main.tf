provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a Cloud Storage bucket for function code
resource "google_storage_bucket" "function_bucket" {
  project       = var.project_id
  name          = "${var.project_id}-function-bucket"
  location      = var.region
  force_destroy = false  # Set to false to prevent bucket deletion
}

# Upload the function code to the bucket
resource "google_storage_bucket_object" "function_zip" {
  name   = "station_status.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "${path.module}/function.zip"
}

# Create the Cloud Function
resource "google_cloudfunctions2_function" "function" {
  project     = var.project_id
  name        = "station_status"
  location    = var.region
  description = "My HTTP Cloud Function"

  build_config {
    runtime     = "python310"
    entry_point = "get_station_status"
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    service_account_email = var.service_account_email # "cloud-function-service-account@${var.project_id}.iam.gserviceaccount.com"
    min_instance_count    = 0
    max_instance_count    = 2
    available_memory      = "128Mi"
    ingress_settings      = "ALLOW_ALL"
  }
}

# Output the URL of the Cloud Function
output "url" {
  value = google_cloudfunctions2_function.function.service_config[0].uri
}

# Create a Pub/Sub topic
resource "google_pubsub_topic" "station_status" {
  name = "station-status"
  message_retention_duration = "86600s"
}

# Create a Cloud Storage bucket for function code
resource "google_storage_bucket" "function_bucket_pull" {
  project       = var.project_id
  name          = "${var.project_id}-function-bucket-pull"
  location      = var.region
  force_destroy = false  # Set to false to prevent bucket deletion
}

# Upload the function code to the bucket
resource "google_storage_bucket_object" "function_zip1" {
  name   = "pull_station_stat.zip"
  bucket = google_storage_bucket.function_bucket_pull.name
  source = "${path.module}/pull_station_stat.zip"
}

# Create the cloud function for pulling the station status 
resource "google_cloudfunctions2_function" "function1" {
  name        = "pull_station_status"
  runtime     = "python310"  # Adjust the runtime according to your code
  entry_point = "pull_station_status"
  region      = var.region
  project     = var.project_id

  source_archive_bucket = google_storage_bucket.function_bucket_pull.name
  source_archive_object = google_storage_bucket_object.function_zip1.name

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.station_status.id
  }

  build_config {
    runtime = "python310"
  }

  service_config {
    available_memory = "256M"  # Set the memory (e.g., 128M, 256M, 512M, 1G, etc.)
    min_instance_count = 0    # Set the minimum number of instances
    max_instance_count = 2    # Set the maximum number of instances
  }

  environment_variables = {
    PUBSUB_TOPIC = google_pubsub_topic.station_status.name
  }
}

# Create the BigQuery dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.dataset_id
  project    = var.project_id
  location   = var.region
}

# Create the STATION_STATUS_NRT BigQuery table
resource "google_bigquery_table" "station_status_nrt_table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "STATION_STATUS_NRT"
  project    = var.project_id
  schema     = jsonencode(var.station_status_nrt_schema)
}

# Create the STATION_INFO BigQuery table
resource "google_bigquery_table" "station_info_table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "STATION_INFO"
  project    = var.project_id
  schema     = jsonencode(var.station_info_schema)
}

# Create the WEATHER_TABLE BigQuery table
resource "google_bigquery_table" "weather_table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "WEATHER_TABLE"
  project    = var.project_id
  schema     = jsonencode(var.weather_table_schema)
}
