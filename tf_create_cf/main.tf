provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "function_bucket" {
  name          = "${var.project_id}-function-bucket"
  location      = var.region
  force_destroy = false  # Set to false to prevent bucket deletion
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "get_station_status.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "${path.module}/get_station_status.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "station_status"
  description = "My Cloud Function"
  runtime     = "python310"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  trigger_http          = true
  entry_point           = "get_station_status"

  environment_variables = {
    "ENV" = "dev"
  }

  labels = {
    "environment" = "dev"
  }
}

resource "google_cloudfunctions_function_iam_member" "noauth_invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "service_account_invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_service_account.default.email}"
}

resource "google_cloudfunctions_function_iam_member" "service_account_admin" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.function.name
  role           = "roles/cloudfunctions.admin"
  member         = "serviceAccount:${google_service_account.default.email}"
}

output "url" {
  value = google_cloudfunctions_function.function.https_trigger_url
}

