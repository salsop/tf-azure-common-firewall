resource "azurerm_storage_account" "bootstrap" {
  name                      = "bootstrapcontainer${random_string.name.result}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  location                  = var.resource_location
  resource_group_name       = var.resource_group_name
  depends_on                = [azurerm_resource_group.main]
  enable_https_traffic_only = true
}

resource "azurerm_storage_share" "bootstrap" {
  name                 = "bootstrap"
  storage_account_name = azurerm_storage_account.bootstrap.name
  quota                = 2
}

resource "azurerm_storage_share_directory" "plugins" {
  name                 = "plugins"
  share_name           = azurerm_storage_share.bootstrap.name
  storage_account_name = azurerm_storage_account.bootstrap.name

  provisioner "local-exec" {
    command = "az storage file upload-batch --account-name ${azurerm_storage_account.bootstrap.name} --account-key ${azurerm_storage_account.bootstrap.primary_access_key} --destination ${azurerm_storage_share.bootstrap.name}/plugins  --source bootstrap_files/plugins"
  }

}

resource "azurerm_storage_share_directory" "software" {
  name                 = "software"
  share_name           = azurerm_storage_share.bootstrap.name
  storage_account_name = azurerm_storage_account.bootstrap.name

  provisioner "local-exec" {
    command = "az storage file upload-batch --account-name ${azurerm_storage_account.bootstrap.name} --account-key ${azurerm_storage_account.bootstrap.primary_access_key} --destination ${azurerm_storage_share.bootstrap.name}/software  --source bootstrap_files/software"
  }

}

resource "azurerm_storage_share_directory" "license" {
  name                 = "license"
  share_name           = azurerm_storage_share.bootstrap.name
  storage_account_name = azurerm_storage_account.bootstrap.name

}

resource "azurerm_storage_share_directory" "content" {
  name                 = "content"
  share_name           = azurerm_storage_share.bootstrap.name
  storage_account_name = azurerm_storage_account.bootstrap.name

  provisioner "local-exec" {
    command = "az storage file upload-batch --account-name ${azurerm_storage_account.bootstrap.name} --account-key ${azurerm_storage_account.bootstrap.primary_access_key} --destination ${azurerm_storage_share.bootstrap.name}/content  --source bootstrap_files/content"
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "az storage file delete-batch --account-name ${self.storage_account_name} --source bootstrap/content"
    on_failure = continue
  }

}

resource "azurerm_storage_share_directory" "config" {
  name                 = "config"
  share_name           = azurerm_storage_share.bootstrap.name
  storage_account_name = azurerm_storage_account.bootstrap.name

  provisioner "local-exec" {
    command = "az storage file upload-batch --account-name ${azurerm_storage_account.bootstrap.name} --account-key ${azurerm_storage_account.bootstrap.primary_access_key} --destination ${azurerm_storage_share.bootstrap.name}/config  --source ./tmp/${random_string.name.result}/config"
  }

  depends_on = [local_file.initcfg_txt]
}

resource "null_resource" "license" {
  provisioner "local-exec" {
    command = "az storage file upload-batch --account-name ${azurerm_storage_account.bootstrap.name} --account-key ${azurerm_storage_account.bootstrap.primary_access_key} --destination ${azurerm_storage_share.bootstrap.name}/license  --source ./tmp/${random_string.name.result}/license"
  }

  triggers = {
    always_run = var.vmseries.authcodes
  }

  depends_on = [local_file.authcodes]
}

data "template_file" "authcodes" {
  template = file("${path.module}/template_files/authcodes.template")
  vars = {
    authcodes = var.vmseries.authcodes
  }
}

resource "local_file" "authcodes" {
  filename = "./tmp/${random_string.name.result}/license/authcodes"
  content  = data.template_file.authcodes.rendered
}

data "template_file" "initcfg_txt" {
  template = file("${path.module}/template_files/init-cfg.txt.template")
  vars = {
    panorama_server1 = var.panorama.primary
    panorama_server2 = var.panorama.secondary
    template_stack   = local.template_stack_name
    device_group     = local.device_group_name
    vm_auth_key      = var.panorama.vm_auth_key
    pin_id           = var.csp_pin_id
    pin_value        = var.csp_pin_value
  }
}

resource "local_file" "initcfg_txt" {
  filename = "./tmp/${random_string.name.result}/config/init-cfg.txt"
  content  = data.template_file.initcfg_txt.rendered
}
