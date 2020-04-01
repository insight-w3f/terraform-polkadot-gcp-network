variable "gcp_region" {
  default = "us-east1"
}

variable "gcp_project" {
  default = "project"
}

variable "vpc_name" {
  default = "example"
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

module "defaults" {
  source   = "../.."
  project  = var.gcp_project
  region   = var.gcp_region
  vpc_name = var.vpc_name
}
