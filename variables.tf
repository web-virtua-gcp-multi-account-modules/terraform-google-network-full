# ----------------------------------------------------------------#
# Network
# ----------------------------------------------------------------#

variable "name" {
  description = "Name to network."
  type        = string
}

variable "routing_mode" {
  description = "The network-wide routing mode to use, the values can be values are REGIONAL or GLOBAL."
  type        = string
  default     = "REGIONAL"
}

variable "auto_create_subnetworks" {
  description = "When set to true, the network is created in auto subnet mode and it will create a subnet for each region automatically across the 10.128.0.0/9 address range."
  type        = bool
  default     = false
}

variable "description" {
  description = "An optional description of this resource."
  type        = string
  default     = null
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
  default     = null
}

variable "delete_default_routes_on_create" {
  description = "If set to true, default routes (0.0.0.0/0) will be deleted immediately after network creation, if false enable internet access. Defaults to true."
  type        = bool
  default     = true
}

variable "mtu" {
  description = "Maximum Transmission Unit in bytes. The default value is 1460 bytes. The minimum value for this field is 1300 and the maximum value is 8896 bytes (jumbo frames)."
  type        = number
  default     = null
}

variable "enable_ula_internal_ipv6" {
  description = "Enable ULA internal ipv6 on this network. Enabling this feature will assign a /48 from google defined ULA prefix fd20::/20."
  type        = string
  default     = null
}

variable "internal_ipv6_range" {
  description = "When enabling ula internal ipv6, caller optionally can specify the /48 range they want from the google defined ULA prefix fd20::/20..."
  type        = string
  default     = null
}

variable "network_firewall_policy_enforcement_order" {
  description = "Set the order that Firewall Rules and Firewall Policies are evaluated, the values can be BEFORE_CLASSIC_FIREWALL, AFTER_CLASSIC_FIREWALL. Default value is AFTER_CLASSIC_FIREWALL."
  type        = string
  default     = "AFTER_CLASSIC_FIREWALL"
}

variable "firewalls" {
  description = "List with firewalls configuration"
  type = list(object({
    name                    = optional(string)
    direction               = optional(string, "INGRESS")
    description             = optional(string, "Firewall description")
    log_metadata            = optional(string)
    priority                = optional(number, 100)
    disabled                = optional(bool, false)
    target_tags             = optional(list(string))
    destination_ranges      = optional(list(string))
    source_ranges           = optional(list(string))
    source_service_accounts = optional(list(string))
    target_service_accounts = optional(list(string))
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })))
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })))
  }))
  default = [
    {
      name        = "tf-vpc-main-allow-egress"
      direction   = "EGRESS"
      description = "Firewall egress - allows outbound traffic"
      target_tags = ["public", "private"]
      allow = [
        {
          protocol = "all"
        }
      ]
    },
    {
      name        = "tf-vpc-main-restrict-ingress"
      direction   = "INGRESS"
      description = "Firewall ingress - prohibits inbound traffic"
      priority    = 1000
      target_tags   = ["private"] 
      source_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "all"
        }
      ]
    }
  ]
}

# ----------------------------------------------------------------#
# Router
# ----------------------------------------------------------------#
variable "public_routes" {
  description = "List with routes configuration"
  type = list(object({
    name                   = optional(string)
    dest_range             = optional(string, "0.0.0.0/0")
    next_hop_gateway       = optional(string, "default-internet-gateway")
    description            = optional(string, "Public route table")
    priority               = optional(number, 100)
    next_hop_ip            = optional(string)
    next_hop_vpn_tunnel    = optional(string)
    project                = optional(string)
    next_hop_instance_zone = optional(string)
    tags                   = optional(list(string), ["public"])
  }))
  default = [
    {
      dest_range = "0.0.0.0/0"
    }
  ]
}

# ----------------------------------------------------------------#
# Subnets
# ----------------------------------------------------------------#
variable "public_subnets" {
  description = "List with customized public subnets configuration"
  type = list(object({
    cidr_block                       = string                          # The range of internal addresses that are owned by this subnetwork. Provide this property when you create the subnetwork. For example, 10.0.0.0/8 or 192.168.0.0/16.
    region                           = optional(string, "us-central1") # The GCP region for this subnetwork.
    private_ip_google_access         = optional(string, "true")        # When enabled, VMs in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access.
    name                             = optional(string)                # The name of the subnet
    private_ipv6_google_access       = optional(string)                # The private IPv6 google access type for the VMs in this subnet.
    description                      = optional(string)                # The purpose of the resource. This field can be either PRIVATE, REGIONAL_MANAGED_PROXY, GLOBAL_MANAGED_PROXY, PRIVATE_SERVICE_CONNECT or PRIVATE_NAT(Beta). A subnet with purpose set to REGIONAL_MANAGED_PROXY is a user-created subnetwork that is reserved for regional Envoy-based load balancers.
    purpose                          = optional(string)                # The role of subnetwork. Currently, this field is only used when purpose is REGIONAL_MANAGED_PROXY. The value can be set to ACTIVE or BACKUP.
    role                             = optional(string)                # The purpose of the resource. This field can be either PRIVATE, REGIONAL_MANAGED_PROXY, GLOBAL_MANAGED_PROXY, PRIVATE_SERVICE_CONNECT or PRIVATE_NAT(Beta). A subnet with purpose set to REGIONAL_MANAGED_PROXY is a user-created subnetwork that is reserved for regional Envoy-based load balancers. 
    stack_type                       = optional(string)                # The role of subnetwork. Currently, this field is only used when purpose is REGIONAL_MANAGED_PROXY. The value can be set to ACTIVE or BACKUP. 
    description                      = optional(string)                # Description to subnet
    stack_type                       = optional(string)                # The stack type for this subnet to identify whether the IPv6 feature is enabled or not. If not specified IPV4_ONLY will be used. Possible values are: IPV4_ONLY, IPV4_IPV6, IPV6_ONLY.
    ipv6_access_type                 = optional(string)                # The access type of IPv6 address this subnet holds. It's immutable and can only be specified during creation or the first time the subnet is updated into IPV4_IPV6 dual stack. If the ipv6_type is EXTERNAL then this subnet cannot enable direct path. Possible values are: EXTERNAL, INTERNAL.
    external_ipv6_prefix             = optional(string)                # The range of external IPv6 addresses that are owned by this subnetwork.
    send_secondary_ip_range_if_empty = optional(string)                # Controls the removal behavior of secondary_ip_range. When false, removing secondary_ip_range from config will not produce a diff as the provider will default to the API's value.

    secondary_ip_range = optional(list(object({  # An array of configurations for secondary IP ranges for VM instances contained in this subnetwork. The primary IP of such VM must belong to the primary ipCidrRange of the subnetwork.
      range_name              = string           # The name associated with this subnetwork secondary range, used when adding an alias IP range to a VM instance. 
      reserved_internal_range = optional(string) #+++ The ID of the reserved internal range. Must be prefixed with networkconnectivity.googleapis.com E.g. networkconnectivity.googleapis.com/projects/{project}/locations/global/internalRanges/{rangeId}
    })))

    log_config = optional(object({                  # This field denotes the VPC flow logging options for this subnetwork. If logging is enabled, logs are exported to Cloud Logging.
      aggregation_interval = optional(string)       # Can only be specified if VPC flow logging for this subnetwork is enabled. Toggles the aggregation interval for collecting flow logs.  Default value is INTERVAL_5_SEC. Possible values are: INTERVAL_5_SEC, INTERVAL_30_SEC, INTERVAL_1_MIN, INTERVAL_5_MIN, INTERVAL_10_MIN, INTERVAL_15_MIN.
      flow_sampling        = optional(string)       # Can only be specified if VPC flow logging for this subnetwork is enabled. The value of the field must be in [0, 1].
      metadata             = optional(string)       # Can only be specified if VPC flow logging for this subnetwork is enabled. Configures whether metadata fields should be added to the reported VPC flow logs. Default value is INCLUDE_ALL_METADATA. Possible values are: EXCLUDE_ALL_METADATA, INCLUDE_ALL_METADATA, CUSTOM_METADATA.
      filter_expr          = optional(string)       # Export filter used to define which VPC flow logs should be logged, as as CEL expression. 
      metadata_fields      = optional(list(string)) # List of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM_METADATA.
    }))
  }))
  default = []
}

variable "private_subnets" {
  description = "List with customized privates subnets configuration"
  type = list(object({
    cidr_block                       = string
    region                           = optional(string, "us-central1")
    private_ip_google_access         = optional(string, "true")
    name                             = optional(string)
    private_ipv6_google_access       = optional(string)
    description                      = optional(string)
    purpose                          = optional(string)
    role                             = optional(string)
    stack_type                       = optional(string)
    description                      = optional(string)
    stack_type                       = optional(string)
    ipv6_access_type                 = optional(string)
    external_ipv6_prefix             = optional(string)
    send_secondary_ip_range_if_empty = optional(string)

    secondary_ip_range = optional(list(object({
      range_name              = string
      reserved_internal_range = optional(string)
    })))

    log_config = optional(object({
      aggregation_interval = optional(string)
      flow_sampling        = optional(string)
      metadata             = optional(string)
      filter_expr          = optional(string)
      metadata_fields      = optional(list(string))
    }))
  }))
  default = []
}

variable "nat_private_router_config" {
  description = "The configuration to router and router NAT to private connections."
  type = object({
    nat_name                               = optional(string)
    nat_ip_allocate_option                 = optional(string, "AUTO_ONLY")
    nat_source_subnetwork_ip_ranges_to_nat = optional(string, "LIST_OF_SUBNETWORKS")
    nat_source_ip_ranges_to_nat            = optional(list(string), ["ALL_IP_RANGES"])
    router_name                            = optional(string)
    router_description                     = optional(string, "Private router to NAT")
    router_encrypted_interconnect_router   = optional(string)

    router_bgp = optional(object({
      asn               = optional(number, 64514)
      advertise_mode    = optional(string, "CUSTOM")
      advertised_groups = optional(list(string), ["ALL_SUBNETS"])
      advertised_ip_ranges = optional(list(object({
        range       = string
        description = optional(string)
      })), [])
    }))
  })
  default = {
    nat_ip_allocate_option = "AUTO_ONLY"
  }
}
