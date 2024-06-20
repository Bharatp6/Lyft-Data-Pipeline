terraform {
  backend "gcs" {
    bucket  = "terraform_files_"
    prefix  = "terraform_state"
  }
}


provider "google" {
  credentials = var.google_cloud_keyfile_json
  project     = var.project_id
  region      = var.region
}
