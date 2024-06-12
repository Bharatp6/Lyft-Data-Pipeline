variable "project_id" {
  description = "The ID of the GCP project to use."
  type        = string
}

variable "region" {
  description = "The GCP region to use."
  type        = string
}

variable "service_account_email" {
  description = "The email of the service account."
  type        = string
}
