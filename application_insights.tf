resource "azurerm_application_insights" "main" {
  count               = 1
  name                = "ngfw-appinsights"
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  depends_on          = [azurerm_resource_group.main]
}
