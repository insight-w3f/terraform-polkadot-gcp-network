resource "google_service_account" "bastion_sg" {
  account_id  = "${var.vpc_name}-${var.bastion_sg_name}"
  description = "${var.bastion_sg_name} service account"
  count       = var.bastion_enabled ? 1 : 0
}

resource "google_compute_firewall" "bastion_sg_ssh" {
  name                    = "${var.vpc_name}-${var.bastion_sg_name}-ssh"
  network                 = module.public-vpc.network_name
  count                   = var.bastion_enabled ? 1 : 0
  description             = "${var.bastion_sg_name} SSH access from corporate IP"
  direction               = "INGRESS"
  source_ranges           = var.corporate_ip == "" ? ["0.0.0.0/0"] : ["${var.corporate_ip}/32"]
  target_service_accounts = google_service_account.bastion_sg[*].email

  allow {
    ports = [
    "22"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "bastion_sg_mon" {
  name                    = "${var.vpc_name}-${var.bastion_sg_name}-monitoring"
  network                 = module.private-vpc.network_name
  count                   = var.bastion_enabled && var.monitoring_enabled ? 1 : 0
  description             = "${var.bastion_sg_name} node exporter"
  direction               = "INGRESS"
  source_service_accounts = var.monitoring_enabled ? google_service_account.monitoring_sg[*].email : []
  target_service_accounts = google_service_account.bastion_sg[*].email

  allow {
    ports = [
      "9100",
    "9428"]
    protocol = "tcp"
  }
}