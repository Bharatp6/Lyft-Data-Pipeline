variable "project_id" {
  description = "The project ID to deploy the resources in"
  type        = string
}

variable "region" {
  description = "The region to deploy the resources in"
  type        = string
  default     = "us-central1"
}
