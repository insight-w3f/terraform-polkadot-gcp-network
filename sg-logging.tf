resource "google_service_account" "logging_sg" {
  account_id  = "${var.vpc_name}-${var.logging_sg_name}"
  description = "${var.logging_sg_name} service account"
  count       = var.logging_enabled ? 1 : 0
}

resource "google_compute_firewall" "logging_sg_ssh" {
  name                    = "${var.vpc_name}-${var.logging_sg_name}-ssh"
  network                 = module.public-vpc.network_name
  count                   = var.logging_enabled && ! var.bastion_enabled ? 1 : 0
  description             = "${var.logging_sg_name} SSH access from corporate IP"
  direction               = "INGRESS"
  source_ranges           = var.corporate_ip == "" ? ["0.0.0.0/0"] : ["${var.corporate_ip}/32"]
  target_service_accounts = google_service_account.logging_sg[*].email

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "logging_sg_bastion_ssh" {
  name                    = "${var.vpc_name}-${var.logging_sg_name}-ssh"
  network                 = module.private-vpc.network_name
  count                   = var.logging_enabled && var.bastion_enabled ? 1 : 0
  description             = "${var.logging_sg_name} SSH access via bastion host"
  direction               = "INGRESS"
  source_service_accounts = google_service_account.bastion_sg[*].email
  target_service_accounts = google_service_account.logging_sg[*].email

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "logging_sg_mon_prom" {
  name                    = "${var.vpc_name}-${var.logging_sg_name}-monitoring"
  network                 = module.private-vpc.network_name
  count                   = var.logging_enabled && var.monitoring_enabled ? 1 : 0
  description             = "${var.logging_sg_name} node exporter"
  direction               = "INGRESS"
  source_service_accounts = google_service_account.monitoring_sg[*].email
  target_service_accounts = google_service_account.logging_sg[*].email

  allow {
    ports = [
    "9100"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "logging_sg_mon_nordstrom" {
  name                    = "${var.vpc_name}-${var.logging_sg_name}-monitoring"
  network                 = module.private-vpc.network_name
  count                   = var.logging_enabled && ! var.monitoring_enabled ? 1 : 0
  description             = "${var.logging_sg_name} node exporter"
  direction               = "INGRESS"
  source_service_accounts = google_service_account.monitoring_sg[*].email
  target_service_accounts = google_service_account.logging_sg[*].email

  allow {
    ports = [
    "9108"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "logging_sg_http_ingress" {
  name                    = "${var.vpc_name}-${var.logging_sg_name}-http_ingress"
  network                 = module.public-vpc.network_name
  description             = "${var.logging_sg_name} HTTP ingress"
  count                   = var.logging_enabled ? 1 : 0
  direction               = "INGRESS"
  source_ranges           = ["0.0.0.0/0"]
  target_service_accounts = google_service_account.logging_sg[*].email

  allow {
    ports = [
    "80"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "logging_sg_consul" {
  name                    = "${var.vpc_name}-${var.logging_sg_name}-consul"
  network                 = module.private-vpc.network_name
  description             = "${var.logging_sg_name} Consul ports"
  count                   = var.logging_enabled && var.consul_enabled ? 1 : 0
  direction               = "INGRESS"
  source_service_accounts = google_service_account.consul_sg[*].email
  target_service_accounts = google_service_account.logging_sg[*].email

  allow {
    ports = [
      "8600",
      "8500",
      "8301",
    "8302"]
    protocol = "tcp"
  }

  allow {
    ports = [
      "8600",
      "8301",
    "8302"]
    protocol = "udp"
  }
}