provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a GCS bucket for delta table
resource "google_storage_bucket" "tf_files" {
  name     = "terraform_files_"  # Replace with a unique bucket name
  location = var.region
}

terraform {
  backend "gcs" {
    bucket  = "terraform_files_"
    key= "key/terraform.tfstate"
    prefix  = "terraform_state"
  }
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
  source = "${path.module}/get_station_status_zip/function.zip"
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
    available_memory      = "256Mi"
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
  source = "${path.module}/pull_station_status_zip/function.zip"
}
 
# Create the Cloud Function for pulling the station status
resource "google_cloudfunctions2_function" "function1" {
  project     = var.project_id
  name        = "pull_station_status"
  location    = var.region
  description = "Function to pull station status"

  build_config {
    runtime     = "python310"
    entry_point = "pull_station_status"
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket_pull.name
        object = google_storage_bucket_object.function_zip1.name
      }
    }
    environment_variables = {
      PUBSUB_TOPIC = google_pubsub_topic.station_status.name
    }
  }

  service_config {
    service_account_email = var.service_account_email  # "cloud-function-service-account@${var.project_id}.iam.gserviceaccount.com"
    available_memory      = "256M"  # Set the memory (e.g., 128M, 256M, 512M, 1G, etc.)
    min_instance_count    = 0       # Set the minimum number of instances
    max_instance_count    = 2       # Set the maximum number of instances
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.station_status.id
  }
}

# Create a GCS bucket for delta table
resource "google_storage_bucket" "my_bucket" {
  name     = "delta_table_bucket"  # Replace with a unique bucket name
  location = var.region
}

# Create folders in the GCS bucket by uploading empty objects
resource "google_storage_bucket_object" "weather_delta_table" {
  name   = "weather_delta_table/"  # The trailing slash indicates it's a folder
  bucket = google_storage_bucket.my_bucket.name
  content       = "Not really a directory, but it's empty." # content = ""  # This creates an empty object to represent the folder
}

resource "google_storage_bucket_object" "station_status_nrt_delta_table" {
  name   = "station_status_nrt_delta_table/"  # The trailing slash indicates it's a folder
  bucket = google_storage_bucket.my_bucket.name
  content       = "Not really a directory, but it's empty." # content = ""  # This creates an empty object to represent the folder
}

resource "google_storage_bucket_object" "station_info_delta_table" {
  name   = "station_info_delta_table/"  # The trailing slash indicates it's a folder
  bucket = google_storage_bucket.my_bucket.name
  content       = "Not really a directory, but it's empty." # content = ""  # This creates an empty object to represent the folder
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
