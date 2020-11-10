
resource "azurerm_virtual_network" "main" {
  count               = var.create_virtual_network ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
  location            = var.resource_location
  address_space       = [var.virtual_network_cidr]

  depends_on = [azurerm_resource_group.main]
}

# Removed App Gateway Subnet For Now
# resource "azurerm_subnet" "appgw" {
#   count                = var.deploy_ingress_appgw ? 1 : 0
#   resource_group_name  = var.resource_group_name
#   name                 = "ingress-appgw-${random_string.name.result}"
#   virtual_network_name = var.virtual_network_name
#   address_prefixes     = [cidrsubnet(var.virtual_network_cidr, 8, 0)]

#   depends_on = [azurerm_virtual_network.main]
# }

resource "azurerm_subnet" "untrust" {
  resource_group_name  = var.resource_group_name
  name                 = "untrust-${random_string.name.result}"
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.virtual_network_cidr, 8, 1)]

  depends_on = [azurerm_virtual_network.main]

}

resource "azurerm_subnet" "trust" {
  resource_group_name  = var.resource_group_name
  name                 = "trust-${random_string.name.result}"
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.virtual_network_cidr, 8, 2)]

  depends_on = [azurerm_virtual_network.main]
}

resource "azurerm_subnet" "loadbalancer" {
  count                = var.deploy_egress_loadbalancer ? 1 : 0
  resource_group_name  = var.resource_group_name
  name                 = "egress-lb-${random_string.name.result}"
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.virtual_network_cidr, 8, 3)]

  depends_on = [azurerm_virtual_network.main]
}

resource "azurerm_subnet" "management" {
  resource_group_name  = var.resource_group_name
  name                 = "management-${random_string.name.result}"
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [cidrsubnet(var.virtual_network_cidr, 8, 4)]

  depends_on = [azurerm_virtual_network.main]
}
