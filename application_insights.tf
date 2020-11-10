resource "azurerm_application_insights" "main" {
  count               = var.vmseries.no_of_instances > 0 ? 1 : 0
  name                = "ngfw-appinsights"
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  depends_on          = [azurerm_resource_group.main]

}
