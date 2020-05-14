locals {
  vpc_ids       = [module.public-vpc.network_self_link, module.private-vpc.network_self_link]
  public_root   = join(".", ["gcp", var.network_name, var.root_domain_name])
  public_domain = join(".", [data.google_client_config.current.region, local.public_root])
}

data cloudflare_zones "this" {
  filter {
    name = var.root_domain_name
  }
}

resource "cloudflare_record" "public_delegation" {
  count   = var.root_domain_name == "" ? 0 : 4
  name    = "${local.public_root}."
  value   = google_dns_managed_zone.this[0].name_servers[count.index]
  type    = "NS"
  zone_id = data.cloudflare_zones.this.zones[0].id
}

resource "google_dns_managed_zone" "this" {
  count    = var.root_domain_name == "" ? 0 : 1
  name     = "${var.vpc_name}-public-root"
  dns_name = "${local.public_root}."
}

resource "google_dns_managed_zone" "root_private" {
  count    = var.create_internal_domain ? 1 : 0
  dns_name = "${var.namespace}.${var.internal_tld}."
  name     = "${var.vpc_name}-private-root"

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
  dns_name = "${local.public_domain}."
  name     = "${var.vpc_name}-public-${data.google_client_config.current.region}"
}

resource "google_dns_record_set" "region_public" {
  count        = var.create_public_regional_subdomain ? 1 : 0
  managed_zone = var.zone_id == "" ? google_dns_managed_zone.this[0].name : var.zone_id
  name         = "${local.public_domain}."
  rrdatas = [
    google_dns_managed_zone.region_public.*.name_servers.0[count.index],
    google_dns_managed_zone.region_public.*.name_servers.1[count.index],
    google_dns_managed_zone.region_public.*.name_servers.2[count.index],
    google_dns_managed_zone.region_public.*.name_servers.3[count.index],
  ]
  ttl  = 30
  type = "NS"
}