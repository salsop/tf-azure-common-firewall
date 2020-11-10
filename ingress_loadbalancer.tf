resource "azurerm_public_ip" "ingress" {
  name                = "ingress-lb-pip-${random_string.name.result}"
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  depends_on          = [azurerm_resource_group.main]
  sku                 = "Standard"
}

resource "azurerm_lb" "ingress" {
  count               = var.deploy_ingress_loadbalancer ? 1 : 0
  resource_group_name = var.resource_group_name
  location            = var.resource_location
  name                = "ingress-lb-${random_string.name.result}"
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.ingress.id
  }
  depends_on = [azurerm_virtual_network.main]
}

resource "azurerm_lb_backend_address_pool" "ethernet0_1" {
  count               = var.deploy_ingress_loadbalancer ? 1 : 0
  name                = "ethernet0_1"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.ingress[0].id
  depends_on          = [azurerm_lb.ingress]
}

resource "azurerm_lb_probe" "tcp22" {
  count               = var.deploy_ingress_loadbalancer ? 1 : 0
  name                = "tcp22"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.ingress[0].id
  port                = 22
}

resource "azurerm_lb_rule" "tcp" {
  count                          = length(var.inbound_tcp_ports)
  name                           = "tcp-${element(var.inbound_tcp_ports, count.index)}"
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.ingress[0].id
  protocol                       = "TCP"
  frontend_port                  = element(var.inbound_tcp_ports, count.index)
  backend_port                   = element(var.inbound_tcp_ports, count.index)
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.ethernet0_1[0].id
  probe_id                       = azurerm_lb_probe.tcp22[0].id
  enable_floating_ip             = true
  depends_on                     = [azurerm_lb.ingress, azurerm_lb_backend_address_pool.ethernet0_1]
}

resource "azurerm_lb_rule" "udp" {
  count                          = length(var.inbound_udp_ports)
  name                           = "udp-${element(var.inbound_udp_ports, count.index)}"
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.ingress[0].id
  protocol                       = "UDP"
  frontend_port                  = element(var.inbound_udp_ports, count.index)
  backend_port                   = element(var.inbound_udp_ports, count.index)
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.ethernet0_1[0].id
  probe_id                       = azurerm_lb_probe.tcp22[0].id
  enable_floating_ip             = true
  depends_on                     = [azurerm_lb.ingress, azurerm_lb_backend_address_pool.ethernet0_1]

}

resource "azurerm_network_interface_backend_address_pool_association" "ethernet0_1" {
  count                   = var.vmseries.no_of_instances
  network_interface_id    = element(azurerm_network_interface.ethernet0_1.*.id, count.index)
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ethernet0_1[0].id
}