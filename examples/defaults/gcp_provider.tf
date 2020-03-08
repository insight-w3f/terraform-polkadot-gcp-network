variable "gcp_region" {
  default = "us-east1"
}

variable "gcp_project" {
  default = "project"
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}