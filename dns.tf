locals {
  vpc_ids       = google_compute_network.vpc_network.id
  public_domain = join(".", [data.google_client_config.current.region, var.environment, var.root_domain_name])
}

data "google_dns_managed_zone" "this" {
  count = var.root_domain_name == "" ? 0 : 1
  name  = "${var.root_domain_name}."
}

resource "google_dns_managed_zone" "root_private" {
  count    = var.create_internal_domain ? 1 : 0
  dns_name = "${var.namespace}.${var.internal_tld}"
  name     = "root_private"

  visibility = "private"

  dynamic "private_visibility_config" {
    for_each = local.vpc_ids
    content {
      networks {
        network_url = private_visibility_config.value
      }
    }
  }
}

resource "google_dns_managed_zone" "region_public" {
  count    = var.create_public_regional_subdomain ? 1 : 0
  dns_name = local.public_domain
  name     = "region_public"
}

resource "google_dns_record_set" "region_public" {
  count        = var.create_public_regional_subdomain ? 1 : 0
  managed_zone = var.zone_id == "" ? data.google_dns_managed_zone.this[0].id : var.zone_id
  name         = local.public_domain
  rrdatas = [
  google_dns_managed_zone.region_public[0].name_servers]
  ttl  = 30
  type = "NS"
}