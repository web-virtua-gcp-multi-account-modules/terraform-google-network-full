# GCP Compute Network for multiples accounts and regions with Terraform module
* This module simplifies creating and configuring of a complete VPC network across multiple accounts and regions on GCP

* Is possible use this module with one region using the standard profile or multi account and regions using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Create file versions.tf with the exemple code below:
```hcl
terraform {
  required_version = ">= 1.1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.64"
    }
  }
}
```

* Criate file provider.tf with the exemple code below:
```hcl
provider "google" {
  alias       = "profile_a"
  credentials = file("your-credentials.json")
  project     = "your-projetct-id-gcp"
  region      = "us-central1"
}


provider "google" {
  alias       = "profile_b"
  credentials = file("your-credentials.json")
  project     = "your-projetct-id-gcp"
  region      = "us-east1"
}
```


## Features enable of Compute Network configurations for this module:
- Compute Network IPV4 and or IPV6
- NAT gateway
- Subnets
- Route
- Router
- Firewall

## Usage exemples

### Compute network with IPV4 and public and private subnets
```hcl
module "vpc_main" {
  source     = "web-virtua-gcp-multi-account-modules/network-full/google"
  name       = "tf-vpc-main"

  public_subnets = [
    {
      cidr_block = "10.0.1.0/24"
      region     = "us-central1"
    },
    {
      cidr_block = "10.0.2.0/24"
      region     = "us-east1"
    }
  ]

  private_subnets = [
    {
      cidr_block = "10.0.3.0/24"
      region     = "us-central1"
    },
    {
      cidr_block = "10.0.4.0/24"
      region     = "us-east1"
    }
  ]

  providers = {
    google = google.websh_us_central1
  }
}
```


## Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_create_subnetworks"></a> [auto\_create\_subnetworks](#input\_auto\_create\_subnetworks) | When set to true, the network is created in auto subnet mode and it will create a subnet for each region automatically across the 10.128.0.0/9 address range. | `bool` | `false` | no |
| <a name="input_delete_default_routes_on_create"></a> [delete\_default\_routes\_on\_create](#input\_delete\_default\_routes\_on\_create) | If set to true, default routes (0.0.0.0/0) will be deleted immediately after network creation, if false enable internet access. Defaults to true. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | An optional description of this resource. | `string` | `null` | no |
| <a name="input_enable_ula_internal_ipv6"></a> [enable\_ula\_internal\_ipv6](#input\_enable\_ula\_internal\_ipv6) | Enable ULA internal ipv6 on this network. Enabling this feature will assign a /48 from google defined ULA prefix fd20::/20. | `string` | `null` | no |
| <a name="input_firewalls"></a> [firewalls](#input\_firewalls) | List with firewalls configuration | `list(object)` | `[]` | no |
| <a name="input_internal_ipv6_range"></a> [internal\_ipv6\_range](#input\_internal\_ipv6\_range) | When enabling ula internal ipv6, caller optionally can specify the /48 range they want from the google defined ULA prefix fd20::/20... | `string` | `null` | no |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | Maximum Transmission Unit in bytes. The default value is 1460 bytes. The minimum value for this field is 1300 and the maximum value is 8896 bytes (jumbo frames). | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to network. | `string` | n/a | yes |
| <a name="input_nat_private_router_config"></a> [nat\_private\_router\_config](#input\_nat\_private\_router\_config) | The configuration to router and router NAT to private connections. | `object` | `{ nat_ip_allocate_option = "AUTO_ONLY" }` | no |
| <a name="input_network_firewall_policy_enforcement_order"></a> [network\_firewall\_policy\_enforcement\_order](#input\_network\_firewall\_policy\_enforcement\_order) | Set the order that Firewall Rules and Firewall Policies are evaluated, the values can be BEFORE\_CLASSIC\_FIREWALL, AFTER\_CLASSIC\_FIREWALL. Default value is AFTER\_CLASSIC\_FIREWALL. | `string` | `"AFTER_CLASSIC_FIREWALL"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List with customized privates subnets configuration | `list(object)` | `[]` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List with customized public subnets configuration | `list(object)` | `[]` | no |
| <a name="input_routing_mode"></a> [routing\_mode](#input\_routing\_mode) | The network-wide routing mode to use, the values can be values are REGIONAL or GLOBAL. | `string` | `"REGIONAL"` | no |

* Model of public_subnets variable
```hcl
variable "public_subnets" {
  description = "List with customized public subnets configuration"
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
  default = [
    {
      cidr_block = "10.0.1.0/24"
      region     = "us-central1"
    },
    {
      cidr_block = "10.0.2.0/24"
      region     = "us-east1"
    }
  ]
}
```

* Model of private_subnets variable
```hcl
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
  default = [
    {
      cidr_block = "10.0.3.0/24"
      region     = "us-central1"
    },
    {
      cidr_block = "10.0.4.0/24"
      region     = "us-east1"
    }
  ]
}
```

* Model of nat_private_router_config variable
```hcl
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
```

* Model of firewalls variable
```hcl
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
```

* Model of public_subnets variable
```hcl

```


## Resources
| Name | Type |
|------|------|
| [google_compute_network.create_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_firewall.create_firewalls](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_route.create_public_route](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_router.create_private_routers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.create_private_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.create_private_subnets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.create_public_subnets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

## Outputs
| Name | Description |
|------|-------------|
| <a name="output_firewall_rules"></a> [firewall\_rules](#output\_firewall\_rules) | Firewall rules |
| <a name="output_network"></a> [network](#output\_network) | VPC |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | The ID of the VPC |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | VPC name |
| <a name="output_network_self_link"></a> [network\_self\_link](#output\_network\_self\_link) | The URI of the VPC |
| <a name="output_private_nat"></a> [private\_nat](#output\_private\_nat) | Private NAT |
| <a name="output_private_routers"></a> [private\_routers](#output\_private\_routers) | Private routers |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | Private subnets |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | VPC project ID |
| <a name="output_public_routes"></a> [public\_routes](#output\_public\_routes) | Public routes |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | Public subnets |
