terraform {
  backend "gcs" {
    bucket      = "terraform_state_st"
    # credentials = var.google_cloud_keyfile_json..
  }
}
