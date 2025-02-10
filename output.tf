output "network" {
  description = "VPC"
  value       = google_compute_network.create_network
}

output "network_name" {
  description = "VPC name"
  value       = google_compute_network.create_network.name
}

output "network_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.create_network.id
}

output "network_self_link" {
  description = "The URI of the VPC"
  value       = google_compute_network.create_network.self_link
}

output "project_id" {
  description = "VPC project ID"
  value       = try(google_compute_network.create_network.project, null)
}

output "firewall_rules" {
  description = "Firewall rules"
  value       = try(google_compute_firewall.create_firewalls, null)
}

output "public_subnets" {
  description = "Public subnets"
  value       = try(google_compute_subnetwork.create_public_subnets, null)
}

output "private_subnets" {
  description = "Private subnets"
  value       = try(google_compute_subnetwork.create_private_subnets, null)
}

output "public_routes" {
  description = "Public routes"
  value       = try(google_compute_route.create_public_route, null)
}

output "private_routers" {
  description = "Private routers"
  value       = try(google_compute_router.create_private_routers, null)
}

output "private_nat" {
  description = "Private NAT"
  value       = try(google_compute_router_nat.create_private_nat, null)
}