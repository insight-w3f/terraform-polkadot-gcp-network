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

  public_subnets_ranges = [for subnet_num in range(local.num_azs) : cidrsubnet(
    var.cidr,
    local.subnet_bits,
  subnet_num)]

  private_subnets_ranges = [for subnet_num in range(local.num_azs) : cidrsubnet(
    var.cidr,
    local.subnet_bits,
    local.num_azs + subnet_num,
  )]

  public_subnets_names  = [for subnet_num in range(local.num_azs) : "${var.vpc_name}-public-${subnet_num}"]
  private_subnets_names = [for subnet_num in range(local.num_azs) : "${var.vpc_name}-private-${subnet_num}"]

  kubernetes_subnet_name = "${var.vpc_name}-eks"

  all_subnets_ranges = flatten(["172.16.0.0/12", local.public_subnets_ranges, local.private_subnets_ranges])
}

data "google_compute_zones" "available" {
  region = data.google_client_config.current.region
  status = "UP"
}

module "public-vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.0.0"

  project_id      = var.project
  network_name    = "${var.vpc_name}-public"
  shared_vpc_host = false

  subnets = concat([
    {
      subnet_name           = local.kubernetes_subnet_name
      subnet_ip             = "172.16.0.0/14"
      subnet_region         = var.region
      subnet_private_access = true
    },
    ],
    [for subnet in range(length(local.public_subnets_names)) :
      {
        subnet_name           = local.public_subnets_names[subnet]
        subnet_ip             = local.public_subnets_ranges[subnet]
        subnet_region         = var.region
        subnet_private_access = true
  }])

  secondary_ranges = {
    eks = [
      {
        range_name            = "${local.kubernetes_subnet_name}-pods"
        ip_cidr_range         = "172.20.0.0/14"
        subnet_private_access = true
      },
      {
        range_name            = "${local.kubernetes_subnet_name}-svcs"
        ip_cidr_range         = "172.24.0.0/14"
        subnet_private_access = true
      },
    ]
  }
}

module "private-vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.0.0"

  project_id                             = var.project
  network_name                           = "${var.vpc_name}-private"
  delete_default_internet_gateway_routes = true
  shared_vpc_host                        = false


  subnets = [for subnet in range(length(local.private_subnets_names)) :
    {
      subnet_name           = local.private_subnets_names[subnet]
      subnet_ip             = local.private_subnets_ranges[subnet]
      subnet_region         = var.region
      subnet_private_access = true
  }]
}