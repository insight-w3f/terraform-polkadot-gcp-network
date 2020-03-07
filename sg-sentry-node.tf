resource "google_service_account" "sentry_node_sg" {
  account_id  = var.sentry_node_sg_name
  description = "${var.sentry_node_sg_name} service account"
  // to keep the output consistent, we'll just keep using the count variable and it'll just be true
  count = true ? 1 : 0
}

resource "google_compute_firewall" "sentry_node_sg_ssh" {
  name          = "${var.sentry_node_sg_name}-ssh"
  network       = google_compute_network.vpc_network.name
  count         = var.bastion_enabled ? 0 : 1
  description   = "${var.sentry_node_sg_name} SSH access from corporate IP"
  direction     = "INGRESS"
  source_ranges = var.corporate_ip == "" ? ["0.0.0.0/0"] : ["${var.corporate_ip}/32"]

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "sentry_node_sg_bastion_ssh" {
  name                    = "${var.sentry_node_sg_name}-ssh"
  network                 = google_compute_network.vpc_network.name
  count                   = var.bastion_enabled ? 1 : 0
  description             = "${var.sentry_node_sg_name} SSH access via bastion host"
  direction               = "INGRESS"
  source_service_accounts = [google_service_account.bastion_sg[*].unique_id]

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "sentry_node_sg_mon" {
  name                    = "${var.sentry_node_sg_name}-monitoring"
  network                 = google_compute_network.vpc_network.name
  count                   = var.monitoring_enabled ? 1 : 0
  description             = "${var.logging_sg_name} node exporter"
  direction               = "INGRESS"
  source_service_accounts = [google_service_account.monitoring_sg[*].unique_id]

  allow {
    ports = [
      "9100",
    "9323"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "sentry_node_sg_hids" {
  name                    = "${var.sentry_node_sg_name}-hids"
  network                 = google_compute_network.vpc_network.name
  count                   = var.hids_enabled ? 1 : 0
  description             = "${var.sentry_node_sg_name} HIDS"
  direction               = "INGRESS"
  source_service_accounts = [google_service_account.monitoring_sg[*].unique_id]

  allow {
    ports = [
      "1514",
    "1515"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "sentry_node_sg_consul" {
  name                    = "${var.sentry_node_sg_name}-consul"
  network                 = google_compute_network.vpc_network.name
  description             = "${var.sentry_node_sg_name} Consul ports"
  count                   = var.consul_enabled ? 1 : 0
  direction               = "INGRESS"
  source_service_accounts = [google_service_account.consul_sg[*].unique_id]

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
  name        = "${var.sentry_node_sg_name}-p2p"
  network     = google_compute_network.vpc_network.name
  description = "${var.sentry_node_sg_name} P2P ports"
  // to keep the output consistent, we'll just keep using the count variable and it'll just be true
  count     = true ? 1 : 0
  direction = "INGRESS"

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