terraform {
  backend "gcs" {
    bucket  = "terraform_files_"
    prefix  = "terraform_state"
  }
}
