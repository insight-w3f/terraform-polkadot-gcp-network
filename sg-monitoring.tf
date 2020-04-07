resource "google_service_account" "monitoring_sg" {
  account_id  = "${var.vpc_name}-${var.monitoring_sg_name}"
  description = "${var.monitoring_sg_name} service account"
  count       = var.monitoring_enabled ? 1 : 0
}

resource "google_compute_firewall" "monitoring_sg_http_ingress" {
  name                    = "${var.vpc_name}-${var.monitoring_sg_name}-http-ingress"
  network                 = module.public-vpc.network_name
  description             = "${var.monitoring_sg_name} HTTP ingress"
  count                   = var.monitoring_enabled ? 1 : 0
  direction               = "INGRESS"
  source_ranges           = ["0.0.0.0/0"]
  target_service_accounts = google_service_account.monitoring_sg[*].email

  allow {
    ports = [
    "80"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "monitoring_sg_ssh" {
  name                    = "${var.vpc_name}-${var.monitoring_sg_name}-ssh"
  network                 = module.public-vpc.network_name
  count                   = var.monitoring_enabled && ! var.bastion_enabled ? 1 : 0
  description             = "${var.monitoring_sg_name} SSH access from corporate IP"
  direction               = "INGRESS"
  source_ranges           = var.corporate_ip == "" ? ["0.0.0.0/0"] : ["${var.corporate_ip}/32"]
  target_service_accounts = google_service_account.monitoring_sg[*].email

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "monitoring_sg_bastion_ssh" {
  name                    = "${var.vpc_name}-${var.monitoring_sg_name}-ssh"
  network                 = module.private-vpc.network_name
  count                   = var.monitoring_enabled && var.bastion_enabled ? 1 : 0
  description             = "${var.bastion_sg_name} SSH access via bastion host"
  direction               = "INGRESS"
  source_service_accounts = google_service_account.bastion_sg[*].email
  target_service_accounts = google_service_account.monitoring_sg[*].email

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "monitoring_sg_consul" {
  name                    = "${var.vpc_name}-${var.monitoring_sg_name}-consul"
  network                 = module.private-vpc.network_name
  description             = "${var.monitoring_sg_name} Consul ports"
  count                   = var.monitoring_enabled && var.consul_enabled ? 1 : 0
  direction               = "INGRESS"
  source_service_accounts = google_service_account.consul_sg[*].email
  target_service_accounts = google_service_account.monitoring_sg[*].email

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