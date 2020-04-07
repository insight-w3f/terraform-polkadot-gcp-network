resource "google_service_account" "sentry_node_sg" {
  account_id  = "${var.vpc_name}-${var.sentry_node_sg_name}"
  description = "${var.sentry_node_sg_name} service account"
  // to keep the output consistent, we'll just keep using the count variable and it'll just be true
  count = true ? 1 : 0
}

resource "google_compute_firewall" "sentry_node_sg_ssh" {
  name                    = "${var.vpc_name}-${var.sentry_node_sg_name}-ssh"
  network                 = module.public-vpc.network_name
  count                   = var.bastion_enabled ? 0 : 1
  description             = "${var.sentry_node_sg_name} SSH access from corporate IP"
  direction               = "INGRESS"
  source_ranges           = var.corporate_ip == "" ? ["0.0.0.0/0"] : ["${var.corporate_ip}/32"]
  target_service_accounts = google_service_account.sentry_node_sg[*].email

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "sentry_node_sg_bastion_ssh" {
  name                    = "${var.vpc_name}-${var.sentry_node_sg_name}-ssh"
  network                 = module.private-vpc.network_name
  count                   = var.bastion_enabled ? 1 : 0
  description             = "${var.sentry_node_sg_name} SSH access via bastion host"
  direction               = "INGRESS"
  source_service_accounts = google_service_account.bastion_sg[*].email
  target_service_accounts = google_service_account.sentry_node_sg[*].email

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "sentry_node_sg_mon" {
  name                    = "${var.vpc_name}-${var.sentry_node_sg_name}-monitoring"
  network                 = module.private-vpc.network_name
  count                   = var.monitoring_enabled ? 1 : 0
  description             = "${var.logging_sg_name} node exporter"
  direction               = "INGRESS"
  source_service_accounts = google_service_account.monitoring_sg[*].email
  target_service_accounts = google_service_account.sentry_node_sg[*].email

  allow {
    ports = [
      "9100",
    "9323"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "sentry_node_sg_hids" {
  name                    = "${var.vpc_name}-${var.sentry_node_sg_name}-hids"
  network                 = module.private-vpc.network_name
  count                   = var.hids_enabled ? 1 : 0
  description             = "${var.sentry_node_sg_name} HIDS"
  direction               = "INGRESS"
  source_service_accounts = google_service_account.monitoring_sg[*].email
  target_service_accounts = google_service_account.sentry_node_sg[*].email

  allow {
    ports = [
      "1514",
    "1515"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "sentry_node_sg_consul" {
  name                    = "${var.vpc_name}-${var.sentry_node_sg_name}-consul"
  network                 = module.private-vpc.network_name
  description             = "${var.sentry_node_sg_name} Consul ports"
  count                   = var.consul_enabled ? 1 : 0
  direction               = "INGRESS"
  source_service_accounts = google_service_account.consul_sg[*].email
  target_service_accounts = google_service_account.sentry_node_sg[*].email

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

resource "google_compute_firewall" "sentry_node_sg_p2p" {
  name        = "${var.vpc_name}-${var.sentry_node_sg_name}-p2p"
  network     = module.public-vpc.network_name
  description = "${var.sentry_node_sg_name} P2P ports"
  // to keep the output consistent, we'll just keep using the count variable and it'll just be true
  count                   = true ? 1 : 0
  direction               = "INGRESS"
  source_ranges           = ["0.0.0.0/0"]
  target_service_accounts = google_service_account.sentry_node_sg[*].email

  allow {
    ports = [
    "30333"]
    protocol = "tcp"
  }

  allow {
    ports = [
    "51820"]
    protocol = "udp"
  }
}

resource "google_compute_firewall" "sentry_node_sg_api" {
  name        = "${var.vpc_name}-${var.sentry_node_sg_name}-api"
  network     = module.public-vpc.network_name
  description = "${var.sentry_node_sg_name} API ports"
  // to keep the output consistent, we'll just keep using the count variable and it'll just be true
  count                   = true ? 1 : 0
  direction               = "INGRESS"
  source_ranges           = ["0.0.0.0/0"]
  target_service_accounts = google_service_account.sentry_node_sg[*].email

  allow {
    ports = [
    "5500", "9933"]
    protocol = "tcp"
  }
}