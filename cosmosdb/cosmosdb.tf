terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.49.0"
    }
  }
}
module "vm" {
  source                = "./module"
  vnet_address_space    = "10.0.0.0/16"
  subnet_address_prefix = "10.0.2.0/24"

  resource_group = "rg1"
  location    = "East Us"
}