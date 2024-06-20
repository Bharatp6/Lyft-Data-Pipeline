terraform {
  backend "gcs"
 config {
    bucket  = "terraform_state"
    credentials = var.google_cloud_keyfile_json
   }
}

