locals {
  device_group_name   = "azure_${lower(random_string.name.result)}"
  template_name       = "azure_template_${lower(random_string.name.result)}"
  template_stack_name = "azure_stack_${lower(random_string.name.result)}"
}

#----------------------------------------------------------------------------------------------------------------------
# Create Device Group
#----------------------------------------------------------------------------------------------------------------------
resource "panos_panorama_device_group" "azure" {
  name        = local.device_group_name
  description = "Terraform Created DeviceGroup"
}

#----------------------------------------------------------------------------------------------------------------------
# Create Template
#----------------------------------------------------------------------------------------------------------------------
resource "panos_panorama_template" "base" {
  name        = local.template_name
  description = "Terraform Created Template"
}

#----------------------------------------------------------------------------------------------------------------------
# Create Template Stack
#----------------------------------------------------------------------------------------------------------------------
resource "panos_panorama_template_stack" "base" {
  name        = local.template_stack_name
  description = "Terraform Created Template Stack"
  templates   = [panos_panorama_template.base.name]
}

#----------------------------------------------------------------------------------------------------------------------
# Create Virtual Routers
#----------------------------------------------------------------------------------------------------------------------

# Untrust Virtual Router & Routes

resource "panos_panorama_virtual_router" "untrust" {
  name     = "untrust"
  template = panos_panorama_template.base.name
  interfaces = [
    panos_panorama_ethernet_interface.ethernet1_1.name
  ]
}

resource "panos_panorama_static_route_ipv4" "untrust-default" {
  template = panos_panorama_template.base.name

  destination    = "0.0.0.0/0"
  name           = "default"
  virtual_router = panos_panorama_virtual_router.untrust.name
  interface      = panos_panorama_ethernet_interface.ethernet1_1.name
  next_hop       = cidrhost(cidrsubnet(var.virtual_network_cidr, 8, 1), 1)
}

resource "panos_panorama_static_route_ipv4" "untrust-loadbalancer" {
  template = panos_panorama_template.base.name

  destination    = "168.63.129.16/32"
  name           = "azure_load_balancer"
  virtual_router = panos_panorama_virtual_router.untrust.name
  interface      = panos_panorama_ethernet_interface.ethernet1_1.name
  next_hop       = cidrhost(cidrsubnet(var.virtual_network_cidr, 8, 1), 1)
}

resource "panos_panorama_static_route_ipv4" "untrust-appgw" {
  count    = var.deploy_ingress_appgw ? 1 : 0
  template = panos_panorama_template.base.name
  destination    = azurerm_subnet.appgw[0].address_prefix
  name           = "appgw"
  virtual_router = panos_panorama_virtual_router.untrust.name
  interface      = panos_panorama_ethernet_interface.ethernet1_1.name
  next_hop       = cidrhost(cidrsubnet(var.virtual_network_cidr, 8, 1), 1)
}

resource "panos_panorama_static_route_ipv4" "untrust-10" {
  template = panos_panorama_template.base.name
  type = "next-vr"
  destination    = "10.0.0.0/8"
  name           = "10.0.0.0_8"
  virtual_router = panos_panorama_virtual_router.untrust.name
  next_hop       = panos_panorama_virtual_router.trust.name
}

resource "panos_panorama_static_route_ipv4" "untrust-172-16" {
  template = panos_panorama_template.base.name
  type = "next-vr"
  destination    = "172.16.0.0/12"
  name           = "172.16.0.0_12"
  virtual_router = panos_panorama_virtual_router.untrust.name
  next_hop       = panos_panorama_virtual_router.trust.name
}

resource "panos_panorama_static_route_ipv4" "untrust-192-168" {
  template = panos_panorama_template.base.name
  type = "next-vr"
  destination    = "192.168.0.0/16"
  name           = "192.168.0.0_16"
  virtual_router = panos_panorama_virtual_router.untrust.name
  next_hop       = panos_panorama_virtual_router.trust.name
}

# Trust Virtual Router & Routes

resource "panos_panorama_virtual_router" "trust" {
  name     = "trust"
  template = panos_panorama_template.base.name
  interfaces = [
    panos_panorama_ethernet_interface.ethernet1_2.name
  ]
}

resource "panos_panorama_static_route_ipv4" "trust-default" {
  template = panos_panorama_template.base.name
  type           = "next-vr"
  destination    = "0.0.0.0/0"
  name           = "default"
  virtual_router = panos_panorama_virtual_router.trust.name
  next_hop       = panos_panorama_virtual_router.untrust.name
}

resource "panos_panorama_static_route_ipv4" "trust-loadbalancer" {
  template = panos_panorama_template.base.name
  destination    = "168.63.129.16/32"
  name           = "azure_load_balancer"
  virtual_router = panos_panorama_virtual_router.trust.name
  interface      = panos_panorama_ethernet_interface.ethernet1_2.name
  next_hop       = cidrhost(cidrsubnet(var.virtual_network_cidr, 8, 2), 1)
}

resource "panos_panorama_static_route_ipv4" "trust-appgw" {
  count    = var.deploy_ingress_appgw ? 1 : 0
  template = panos_panorama_template.base.name
  type           = "next-vr"
  destination    = azurerm_subnet.appgw[0].address_prefix
  name           = "appgw"
  virtual_router = panos_panorama_virtual_router.trust.name
  next_hop       = panos_panorama_virtual_router.untrust.name
}

resource "panos_panorama_static_route_ipv4" "trust-10" {
  template = panos_panorama_template.base.name
  destination    = "10.0.0.0/8"
  name           = "10.0.0.0_8"
  virtual_router = panos_panorama_virtual_router.trust.name
  interface      = panos_panorama_ethernet_interface.ethernet1_2.name
  next_hop       = cidrhost(cidrsubnet(var.virtual_network_cidr, 8, 2), 1)
}

resource "panos_panorama_static_route_ipv4" "trust-172-16" {
  template = panos_panorama_template.base.name
  destination    = "172.16.0.0/12"
  name           = "172.16.0.0_12"
  virtual_router = panos_panorama_virtual_router.trust.name
  interface      = panos_panorama_ethernet_interface.ethernet1_2.name
  next_hop       = cidrhost(cidrsubnet(var.virtual_network_cidr, 8, 2), 1)
}

resource "panos_panorama_static_route_ipv4" "trust-192-168" {
  template = panos_panorama_template.base.name
  destination    = "192.168.0.0/16"
  name           = "192.168.0.0_16"
  virtual_router = panos_panorama_virtual_router.trust.name
  interface      = panos_panorama_ethernet_interface.ethernet1_2.name
  next_hop       = cidrhost(cidrsubnet(var.virtual_network_cidr, 8, 2), 1)
}

#----------------------------------------------------------------------------------------------------------------------
# Network Zones
#----------------------------------------------------------------------------------------------------------------------

resource "panos_panorama_zone" "trust" {
  name       = "trust"
  template   = panos_panorama_template.base.name
  mode       = "layer3"
  interfaces = [panos_panorama_ethernet_interface.ethernet1_2.name]
}

resource "panos_panorama_zone" "untrust" {
  name       = "untrust"
  template   = panos_panorama_template.base.name
  mode       = "layer3"
  interfaces = [panos_panorama_ethernet_interface.ethernet1_1.name]
}

#----------------------------------------------------------------------------------------------------------------------
# Network Interfaces
#----------------------------------------------------------------------------------------------------------------------

resource "panos_panorama_ethernet_interface" "ethernet1_1" {
  name                      = "ethernet1/1"
  template                  = panos_panorama_template.base.name
  vsys                      = "vsys1"
  mode                      = "layer3"
  enable_dhcp               = true
  create_dhcp_default_route = false
  comment                   = "Terraform Created Interface"
  management_profile        = panos_panorama_management_profile.azure_healthcheck.name
}

resource "panos_panorama_ethernet_interface" "ethernet1_2" {
  name                      = "ethernet1/2"
  template                  = panos_panorama_template.base.name
  vsys                      = "vsys1"
  mode                      = "layer3"
  enable_dhcp               = true
  create_dhcp_default_route = false
  comment                   = "Terraform Created Interface"
  management_profile        = panos_panorama_management_profile.azure_healthcheck.name
}

#----------------------------------------------------------------------------------------------------------------------
# Administrative Tags
#----------------------------------------------------------------------------------------------------------------------

resource "panos_panorama_administrative_tag" "terraform" {
  device_group = panos_panorama_device_group.azure.name

  name    = "TERRAFORM"
  color   = "color1"
  comment = "Created and Managed By Terraform"

  depends_on = [panos_panorama_device_group.azure]
}

resource "panos_panorama_management_profile" "azure_healthcheck" {
  template = panos_panorama_template.base.name

  name          = "azure_healthcheck"
  ssh           = true
  permitted_ips = ["168.63.129.16/32"]
}

#----------------------------------------------------------------------------------------------------------------------
# NAT Rules
#----------------------------------------------------------------------------------------------------------------------

resource "panos_panorama_nat_rule_group" "natrules" {
  device_group = panos_panorama_device_group.azure.name

  # NAT Outbound Traffic 'Trust' to 'Untrust'

  rule {
    name = "NAT Outbound"
    tags = [panos_panorama_administrative_tag.terraform.name]

    original_packet {
      source_addresses = ["any"]
      source_zones     = [panos_panorama_zone.trust.name]

      destination_addresses = ["any"]
      destination_zone      = panos_panorama_zone.untrust.name
    }
    translated_packet {
      destination {
      }
      source {
        dynamic_ip_and_port {
          interface_address {
            interface = "ethernet1/1"
          }
        }

      }
    }
  }
}

#----------------------------------------------------------------------------------------------------------------------
# Security Rules
#----------------------------------------------------------------------------------------------------------------------

resource "panos_panorama_security_policy_group" "secrules" {
  device_group = panos_panorama_device_group.azure.name
  rule {
    applications          = ["any"]
    categories            = ["any"]
    destination_addresses = ["any"]
    destination_zones     = [panos_panorama_zone.untrust.name]
    hip_profiles          = ["any"]
    name                  = "Allow All Outbound"
    services              = ["any"]
    source_addresses      = ["any"]
    source_users          = ["any"]
    source_zones          = [panos_panorama_zone.trust.name]
    tags                  = [panos_panorama_administrative_tag.terraform.name]
  }
}

resource "null_resource" "panorama_commit" {
  provisioner "local-exec" {
    command    = "./scripts/commit.sh ${var.panorama.primary} ${var.panorama.apikey}"
    on_failure = continue
  }
  depends_on = [
    panos_panorama_device_group.azure,
    panos_panorama_template.base,
    panos_panorama_template_stack.base,
    panos_panorama_static_route_ipv4.trust-10,
    panos_panorama_static_route_ipv4.trust-172-16,
    panos_panorama_static_route_ipv4.trust-192-168
  ]
}