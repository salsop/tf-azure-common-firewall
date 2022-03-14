terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.34.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "= 1.2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "= 2.1.0"
    }
    panos = {
      source  = "paloaltonetworks/panos"
      version = "= 1.6.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.0.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "= 2.1.2"
    }
  }
  required_version = ">= 0.13"
}

provider "azurerm" {
  features {}
}

provider "panos" {
  hostname = var.panorama.primary
  api_key  = var.panorama.apikey
}
