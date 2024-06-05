provider "google-beta" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "function_bucket" {
  project     = var.project_id
  name          = "${var.project_id}-function-bucket"
  location      = var.region
  force_destroy = false  # Set to false to prevent bucket deletion
}

resource "google_storage_bucket_object" "function_zip" {
  project = var.project_id
  name   = "get_station_status.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "${path.module}/get_station_status.zip"
}

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
    service_account_email = "cloud-function-service-account@${var.project_id}.iam.gserviceaccount.com"
    min_instance_count    = 0
    max_instance_count    = 1
    available_memory      = "128Mi"
    ingress_settings      = "ALLOW_ALL"
  }

}

resource "google_cloudfunctions2_function_iam_member" "noauth_invoker" {
  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

output "url" {
  value = google_cloudfunctions2_function.function.service_config[0].uri
}
