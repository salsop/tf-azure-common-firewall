
resource "azurerm_network_security_group" "management" {
  name                = "ngfw-nsg-allow-management-${random_string.name.result}"
  location            = var.resource_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "management-inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443", "22"]
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }


  depends_on = [azurerm_resource_group.main]

}

resource "azurerm_network_security_group" "data" {
  name                = "ngfw-nsg-allow-all-${random_string.name.result}"
  location            = var.resource_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "data-inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "data-outbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [azurerm_resource_group.main]

}