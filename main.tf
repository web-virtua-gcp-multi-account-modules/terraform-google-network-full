resource "google_compute_network" "create_network" {
  name                                      = var.name
  routing_mode                              = var.routing_mode
  auto_create_subnetworks                   = var.auto_create_subnetworks
  description                               = var.description
  project                                   = var.project_id
  delete_default_routes_on_create           = var.delete_default_routes_on_create
  mtu                                       = var.mtu
  enable_ula_internal_ipv6                  = var.enable_ula_internal_ipv6
  internal_ipv6_range                       = var.internal_ipv6_range
  network_firewall_policy_enforcement_order = var.network_firewall_policy_enforcement_order
}

# -------------------------------------------------------------------------------------
# Firewall Rules
# -------------------------------------------------------------------------------------
resource "google_compute_firewall" "create_firewalls" {
  count = length(var.firewalls)

  network     = google_compute_network.create_network.id
  name        = var.firewalls[count.index].name != null ? var.firewalls[count.index].name : "${var.name}-allow-egress"
  direction   = var.firewalls[count.index].direction
  description = var.firewalls[count.index].description
  disabled    = var.firewalls[count.index].disabled
  priority    = var.firewalls[count.index].priority

  target_tags             = var.firewalls[count.index].target_tags
  destination_ranges      = var.firewalls[count.index].destination_ranges
  source_ranges           = var.firewalls[count.index].source_ranges
  source_service_accounts = var.firewalls[count.index].source_service_accounts
  target_service_accounts = var.firewalls[count.index].target_service_accounts

  dynamic "allow" {
    for_each = var.firewalls[count.index].allow != null ? var.firewalls[count.index].allow : []
    iterator = item

    content {
      protocol = item.value.protocol
      ports    = item.value.ports
    }
  }

  dynamic "deny" {
    for_each = var.firewalls[count.index].deny != null ? var.firewalls[count.index].deny : []
    iterator = item

    content {
      protocol = item.value.protocol
      ports    = item.value.ports
    }
  }

  dynamic "log_config" {
    for_each = var.firewalls[count.index].log_metadata != null ? [1] : []

    content {
      metadata = var.firewalls[count.index].log_metadata
    }
  }
}

# -------------------------------------------------------------------------------------
# Subnets
# -------------------------------------------------------------------------------------
resource "google_compute_subnetwork" "create_public_subnets" {
  count = length(var.public_subnets)

  network                  = google_compute_network.create_network.id
  name                     = "${var.name}-public-subnet-${var.public_subnets[count.index].region}-${count.index + 1}"
  ip_cidr_range            = var.public_subnets[count.index].cidr_block
  region                   = var.public_subnets[count.index].region
  private_ip_google_access = var.public_subnets[count.index].private_ip_google_access

  dynamic "secondary_ip_range" {
    for_each = var.public_subnets[count.index].secondary_ip_range != null ? var.public_subnets[count.index].secondary_ip_range : []
    iterator = item

    content {
      range_name    = item.value.range_name
      ip_cidr_range = item.value.reserved_internal_range
    }
  }

  dynamic "log_config" {
    for_each = var.public_subnets[count.index].log_config != null ? [var.public_subnets[count.index].log_config] : []
    iterator = item

    content {
      aggregation_interval = item.value.aggregation_interval
      flow_sampling        = item.value.flow_sampling
      metadata             = item.value.metadata
    }
  }
}

resource "google_compute_subnetwork" "create_private_subnets" {
  count = length(var.private_subnets)

  network                  = google_compute_network.create_network.id
  name                     = "${var.name}-private-subnet-${var.private_subnets[count.index].region}-${count.index + 1}"
  ip_cidr_range            = var.private_subnets[count.index].cidr_block
  region                   = var.private_subnets[count.index].region
  private_ip_google_access = var.private_subnets[count.index].private_ip_google_access

  dynamic "secondary_ip_range" {
    for_each = var.private_subnets[count.index].secondary_ip_range != null ? var.private_subnets[count.index].secondary_ip_range : []
    iterator = item

    content {
      range_name    = item.value.range_name
      ip_cidr_range = item.value.reserved_internal_range
    }
  }

  dynamic "log_config" {
    for_each = var.private_subnets[count.index].log_config != null ? [var.private_subnets[count.index].log_config] : []
    iterator = item

    content {
      aggregation_interval = item.value.aggregation_interval
      flow_sampling        = item.value.flow_sampling
      metadata             = item.value.metadata
    }
  }
}

# -------------------------------------------------------------------------------------
# Routes
# -------------------------------------------------------------------------------------
resource "google_compute_route" "create_public_route" {
  count = length(var.public_routes)

  network                = google_compute_network.create_network.id
  name                   = var.public_routes[count.index].name != null ? var.public_routes[count.index].name : "${var.name}-public-route"
  dest_range             = var.public_routes[count.index].dest_range
  next_hop_gateway       = var.public_routes[count.index].next_hop_gateway
  priority               = var.public_routes[count.index].priority
  description            = var.public_routes[count.index].description
  next_hop_ip            = var.public_routes[count.index].next_hop_ip
  next_hop_vpn_tunnel    = var.public_routes[count.index].next_hop_vpn_tunnel
  project                = var.public_routes[count.index].project
  next_hop_instance_zone = var.public_routes[count.index].next_hop_instance_zone

  # Enable only to public subnets
  tags = var.public_routes[count.index].tags
}

locals {
  private_subnet_regions = distinct([
    for subnet in var.private_subnets : subnet.region
  ])
}

# Create one private router for each private subnet region
resource "google_compute_router" "create_private_routers" {
  for_each = toset(local.private_subnet_regions)

  network                       = google_compute_network.create_network.id
  region                        = each.value
  name                          = var.nat_private_router_config.router_name != null ? var.nat_private_router_config.router_name : "${var.name}-private-router-${each.value}"
  description                   = var.nat_private_router_config.router_description
  encrypted_interconnect_router = var.nat_private_router_config.router_encrypted_interconnect_router

  dynamic "bgp" {
    for_each = var.nat_private_router_config.router_bgp != null ? [1] : []

    content {
      asn               = var.nat_private_router_config.router_bgp.asn
      advertise_mode    = var.nat_private_router_config.router_bgp.advertise_mode
      advertised_groups = var.nat_private_router_config.router_bgp.advertised_groups

      dynamic "advertised_ip_ranges" {
        for_each = var.nat_private_router_config.router_bgp.advertised_ip_ranges
        iterator = item

        content {
          range       = item.value.range
          description = item.value.description != null ? item.value.description : "Private subnet in ${each.value}"
        }
      }
    }
  }
}

resource "google_compute_router_nat" "create_private_nat" {
  for_each = google_compute_router.create_private_routers

  name                               = var.nat_private_router_config.nat_name != null ? var.nat_private_router_config.nat_name : "${var.name}-nat-${each.value.region}"
  router                             = each.value.name
  region                             = each.value.region
  nat_ip_allocate_option             = var.nat_private_router_config.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.nat_private_router_config.nat_source_subnetwork_ip_ranges_to_nat

  dynamic "subnetwork" {
    for_each = [
      for subnet in google_compute_subnetwork.create_private_subnets :
      subnet if subnet.region == each.value.region
    ]

    content {
      name                    = subnetwork.value.id
      source_ip_ranges_to_nat = var.nat_private_router_config.nat_source_ip_ranges_to_nat
    }
  }
}
