resource "azurerm_lb" "egress" {
  count               = var.deploy_egress_loadbalancer ? 1 : 0
  resource_group_name = var.resource_group_name
  location            = var.resource_location
  name                = "egress-lb-${random_string.name.result}"
  depends_on          = [azurerm_virtual_network.main]
  sku                 = "Standard"

  frontend_ip_configuration {
    name      = "LoadBalancerIP"
    subnet_id = azurerm_subnet.loadbalancer[0].id
  }
}

resource "azurerm_lb_probe" "egress_tcp22" {
  count               = var.deploy_egress_loadbalancer ? 1 : 0
  name                = "tcp22"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.egress[0].id
  port                = 22

}

resource "azurerm_lb_backend_address_pool" "ethernet0_2" {
  count               = var.deploy_egress_loadbalancer ? 1 : 0
  name                = "ethernet0_2"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.egress[0].id
}

resource "azurerm_lb_rule" "allports" {
  count                          = var.deploy_egress_loadbalancer ? 1 : 0
  name                           = "all-ports"
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.egress[0].id
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "LoadBalancerIP"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.ethernet0_2[0].id
  probe_id                       = azurerm_lb_probe.egress_tcp22[0].id
  enable_floating_ip             = true
  depends_on                     = [azurerm_network_interface.ethernet0_2]
}

resource "azurerm_network_interface_backend_address_pool_association" "ethernet0_2" {
  count                   = var.vmseries.no_of_instances
  network_interface_id    = element(azurerm_network_interface.ethernet0_2.*.id, count.index)
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ethernet0_2[0].id
  depends_on              = [azurerm_network_interface.ethernet0_2]
}