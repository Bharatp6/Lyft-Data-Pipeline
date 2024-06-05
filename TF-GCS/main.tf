provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_file)
}

resource "google_storage_bucket" "bucket" {
  name     = var.bucket_name
  location = var.region
}

output "bucket_name" {
  value = google_storage_bucket.bucket.name
}

