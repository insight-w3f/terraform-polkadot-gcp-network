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
  value       = google_service_account.bastion_sg[*].unique_id
  description = "UID of the service account for the bastion host"
}

output "consul_security_group_id" {
  value       = google_service_account.consul_sg[*].unique_id
  description = "UID of the service account for the Consul servers"
}

output "hids_security_group_id" {
  value       = google_service_account.hids_sg[*].unique_id
  description = "UID of the service account for the HIDS group"
}

output "logging_security_group_id" {
  value       = google_service_account.consul_sg[*].unique_id
  description = "UID of the service account for the logging group"
}

output "monitoring_security_group_id" {
  value       = google_service_account.monitoring_sg[*].unique_id
  description = "UID of the service account for the monitoring group"
}

output "sentry_security_group_id" {
  value       = google_service_account.sentry_node_sg[*].unique_id
  description = "UID of the service account for the sentry group"
}

output "vault_security_group_id" {
  value       = google_service_account.vault_sg[*].unique_id
  description = "UID of the service account for the vault group"
}

#####
# VPC
#####
output "vpc_id" {
  value       = google_compute_network.vpc_network.id
  description = "The ID of the VPC"
}

output "public_subnets" {
  value       = google_compute_subnetwork.public_subnets[*].id
  description = "The IDs of the public subnets"
}

output "private_subnets" {
  value       = google_compute_subnetwork.private_subnets[*].id
  description = "The IDs of the private subnets"
}

output "public_subnet_cidr_blocks" {
  value       = google_compute_subnetwork.public_subnets[*].ip_cidr_range
  description = "CIDR ranges for the public subnets"
}

output "private_subnets_cidr_blocks" {
  value       = google_compute_subnetwork.private_subnets[*].ip_cidr_range
  description = "CIDR ranges for the private subnets"
}

output "azs" {
  value       = local.azs
  description = "Availability zones"
}
