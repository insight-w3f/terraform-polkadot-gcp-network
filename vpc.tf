locals {
  //    Logic for AZs is azs variable > az_num variable > max azs for region
  az_num = chunklist(data.google_compute_zones.available.names, var.num_azs)[0]
  az_max = data.google_compute_zones.available.names
  azs    = coalescelist(var.azs, local.az_num, local.az_max)

  num_azs = length(local.azs)
  //  TODO: If making additional subnets, this will change
  subnet_num   = 2
  subnet_count = local.subnet_num * local.num_azs

  subnet_bits = ceil(log(local.subnet_count, 2))

  public_subnets = [for subnet_num in range(local.num_azs) : cidrsubnet(
    var.cidr,
    local.subnet_bits,
  subnet_num)]

  private_subnets = [for subnet_num in range(local.num_azs) : cidrsubnet(
    var.cidr,
    local.subnet_bits,
    local.num_azs + subnet_num,
  )]
}

data "google_compute_zones" "available" {
  region = data.google_client_config.current.region
  status = "UP"
}

resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_subnets" {
  count = local.num_azs

  name                     = "${var.vpc_name}-private-${count.index}"
  ip_cidr_range            = local.private_subnets[count.index]
  region                   = data.google_client_config.current.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true

}

resource "google_compute_subnetwork" "public_subnets" {
  count = local.num_azs

  name          = "${var.vpc_name}-public-${count.index}"
  ip_cidr_range = local.public_subnets[count.index]
  region        = data.google_client_config.current.region
  network       = google_compute_network.vpc_network.id
}

// Create internet routes for public subnets

resource "google_compute_route" "public_inet_routes" {
  count            = length(local.public_subnets)
  dest_range       = "0.0.0.0/0"
  name             = "${var.vpc_name}-inet-${count.index}"
  network          = google_compute_network.vpc_network.id
  next_hop_gateway = "default-internet-gateway"
}