variable "panorama" {
  default = {
    # Active Panorama DNS Name or IP
    primary = ""
    # Standby Panorama DNS Name or IP (can be blank)
    secondary = ""
    # VM Auth Key from Panorama to Authenticate VM-Series
    vm_auth_key = ""
    # API Key for Panorama Authentication
    apikey = ""
  }
}


# Resource Group Settings
variable "create_resource_group" { default = true }
variable "resource_group_name" { description = "Azure Resource Group Name for Deployment" }

# Resource Location
variable "resource_location" { default = "West Europe" }

# Virtual Network Settings
variable "create_virtual_network" { default = true }
variable "virtual_network_name" { default = "vnet" }
variable "virtual_network_cidr" { default = "172.16.0.0/16" }

# Ingress Application Gateway
variable "deploy_ingress_appgw" { default = false }

# Ingress Load Balancer
variable "deploy_ingress_loadbalancer" { default = true }

# Array of Ports to allow ingress
variable "inbound_tcp_ports" { default = [80] }
variable "inbound_udp_ports" { default = [] }

# Egress Load Balancer
variable "deploy_egress_loadbalancer" { default = true }

# VM-Series Deployment Options
variable "vmseries" {
  default = {
    no_of_instances = 1

    # PAN-OS Offer "vmseries-flex" or the legacy "vmseries1"
    offer = "vmseries-flex"

    # PAN-OS Version 
    # -> az vm image list --publisher "paloaltonetworks" --offer "vmseries-flex" --all --output table
    version = "10.0.1"

    # VM-Series License Option: byol, bundle1 or bundle2
    license   = "bundle2"
    authcodes = ""

    # Username and Password:
    admin_username = "panw-demo-admin"
    admin_password = "Pal0Alto!"

    # VM-Series Azure Instance Size
    instance_size = "Standard_DS3_v2"

    # Public IP Management
    public_management = true

  }
}

variable "csp_pin_id" {
  description = "Customer Support Portal Regitration Pin ID"
  default     = ""
}

variable "csp_pin_value" {
  description = "Customer Support Portal Registration Pin Value"
}




