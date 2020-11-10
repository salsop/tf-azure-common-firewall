resource "azurerm_public_ip" "appgw" {
  count = var.deploy_ingress_appgw ? 1 : 0

  name                = "ingress-appgw-pip-${random_string.name.result}"
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  depends_on          = [azurerm_resource_group.main]
  sku                 = "Standard"
}

locals {
  frontend_ip_configuration_name = "public-${local.frontend_port_name}"
  frontend_port_name             = "tcp80"
  backend_address_pool_name      = "vmseries"
  http_setting_name              = "http-${local.frontend_port_name}"
  listener_name                  = "redapp"
  request_routing_rule_name      = "${local.listener_name}-${local.http_setting_name}-${local.backend_address_pool_name}"
}

resource "azurerm_application_gateway" "ingress" {
  count = var.deploy_ingress_appgw ? 1 : 0

  name                = "ingress-appgw-${random_string.name.result}"
  resource_group_name = var.resource_group_name
  location            = var.resource_location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgw[0].id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw[0].id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "vmseries" {
  count                   = var.deploy_ingress_appgw ? var.vmseries.no_of_instances : 0
  network_interface_id    = azurerm_network_interface.ethernet0_1[count.index].id
  backend_address_pool_id = azurerm_application_gateway.ingress[0].backend_address_pool[0].id
  ip_configuration_name   = "ipconfig1"
}