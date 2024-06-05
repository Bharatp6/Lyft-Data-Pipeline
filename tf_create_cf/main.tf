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

resource "google_cloud_run_service" "default" {
  name     = "station-status"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/station-status"
        resources {
          limits = {
            memory = "128Mi"
          }
        }
        env {
          name  = "ENV"
          value = "dev"
        }
      }
      service_account_name = "cloud-function-service-account@${var.project_id}.iam.gserviceaccount.com"
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloudfunctions2_function" "function" {
  name        = "station_status"
  description = "My Cloud Function"
  runtime     = "python310"
  build_config {
    runtime = "python310"
    entry_point = "get_station_status"
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }
  service_config {
    service = google_cloud_run_service.default.name
    max_instance_count = 1
    min_instance_count = 0
  }
}

resource "google_cloud_run_service_iam_binding" "noauth_invoker" {
  location = google_cloud_run_service.default.location
  project  = var.project_id
  service  = google_cloud_run_service.default.name

  role    = "roles/run.invoker"
  members = ["allUsers"]
}

resource "google_cloud_run_service_iam_binding" "service_account_invoker" {
  location = google_cloud_run_service.default.location
  project  = var.project_id
  service  = google_cloud_run_service.default.name

  role    = "roles/run.invoker"
  members = ["serviceAccount:cloud-function-service-account@${var.project_id}.iam.gserviceaccount.com"]
}

resource "google_cloud_run_service_iam_binding" "service_account_admin" {
  location = google_cloud_run_service.default.location
  project  = var.project_id
  service  = google_cloud_run_service.default.name

  role    = "roles/run.admin"
  members = ["serviceAccount:cloud-function-service-account@${var.project_id}.iam.gserviceaccount.com"]
}

output "url" {
  value = google_cloud_run_service.default.status[0].url
}

variable "project_id" {
  description = "The project ID to deploy the resources in"
  type        = string
}

variable "region" {
  description = "The region to deploy the resources in"
  type        = string
  default     = "us-central1"
}
