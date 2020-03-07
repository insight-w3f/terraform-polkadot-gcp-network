variable "gcp_region" {
  default = "us-east1"
}

variable "gcp_project" {
  default = "project"
}

variable "gcp_zone" {
  default = "us-east1-b"
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}