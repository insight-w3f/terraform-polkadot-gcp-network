#####
# DNS
#####
output "root_domain_name" {
  value       = var.root_domain_name
  description = "The name of the root domain"
}

output "internal_tld" {
  value       = var.internal_tld
  description = "The name of the internal domain"
}

output "public_regional_domain" {
  value       = var.create_public_regional_subdomain ? local.public_domain : ""
  description = "The public regional domain"
}

#####
# SGs
#####
output "bastion_security_group_id" {
  value       = google_service_account.bastion_sg[*].email
  description = "UID of the service account for the bastion host"
}

output "consul_security_group_id" {
  value       = google_service_account.consul_sg[*].email
  description = "UID of the service account for the Consul servers"
}

output "hids_security_group_id" {
  value       = google_service_account.hids_sg[*].email
  description = "UID of the service account for the HIDS group"
}

output "logging_security_group_id" {
  value       = google_service_account.consul_sg[*].email
  description = "UID of the service account for the logging group"
}

output "monitoring_security_group_id" {
  value       = google_service_account.monitoring_sg[*].email
  description = "UID of the service account for the monitoring group"
}

output "sentry_security_group_id" {
  value       = google_service_account.sentry_node_sg[*].email
  description = "UID of the service account for the sentry group"
}

output "vault_security_group_id" {
  value       = google_service_account.vault_sg[*].email
  description = "UID of the service account for the vault group"
}

#####
# VPC
#####
output "public_vpc_id" {
  value       = module.public-vpc.network_self_link
  description = "The ID of the public VPC"
}

output "public_vpc_name" {
  value       = module.public-vpc.network_name
  description = "The name of the public VPC"
}

output "private_vpc_id" {
  value       = module.private-vpc.network_self_link
  description = "The ID of the private VPC"
}

output "private_vpc_name" {
  value       = module.private-vpc.network_name
  description = "The name of the private VPC"
}

output "public_subnets" {
  value       = module.public-vpc.subnets_self_links
  description = "The IDs of the public subnets"
}

output "public_subnets_names" {
  value       = module.public-vpc.subnets_names
  description = "The names of the public subnets"
}

output "private_subnets" {
  value       = module.private-vpc.subnets_self_links
  description = "The IDs of the private subnets"
}

output "private_subnets_names" {
  value       = module.private-vpc.subnets_names
  description = "The names of the public subnets"
}

output "public_subnet_cidr_blocks" {
  value       = local.public_subnets_ranges
  description = "CIDR ranges for the public subnets"
}

output "private_subnets_cidr_blocks" {
  value       = local.private_subnets_ranges
  description = "CIDR ranges for the private subnets"
}

output "azs" {
  value       = local.azs
  description = "Availability zones"
}

output "kubernetes_subnet" {
  value = module.public-vpc.subnets_names[0]
}