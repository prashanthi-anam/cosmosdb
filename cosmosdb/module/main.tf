# main.tf


resource "azurerm_resource_group" "app_grp" {
    name = var.resource_group
    location = var.location
    
  
}

resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = ["${var.vnet_address_space}"]
  depends_on = [ azurerm_resource_group.app_grp ]
}

resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["${var.subnet_address_prefix}"]
  depends_on = [
    azurerm_virtual_network.app_network
  ]
}



resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "db" {
  name                          = "tfex-cosmos-db-${random_integer.ri.result}"
  location                      = var.location
  resource_group_name           = var.resource_group
  offer_type                    = "Standard"
  kind                          = "MongoDB"
  public_network_access_enabled = false
  enable_automatic_failover     = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = "eastus"
    failover_priority = 1
  }

  geo_location {
    location          = "westus"
    failover_priority = 0
  }
  depends_on = [ azurerm_resource_group.app_grp ]
}


resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "mycosmodb.private"
  resource_group_name = var.resource_group
  depends_on = [ azurerm_resource_group.app_grp ]

}
resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_vnet_link" {
  name                  = "cosmosdb-private-dns-zone-link"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.app_network.id
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = "cosmodbprivateendpoint"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = azurerm_subnet.SubnetA.id
  private_service_connection {
    name                           = "cosmosdb-private-endpoint-connection"
    private_connection_resource_id = azurerm_cosmosdb_account.db.id
    subresource_names              = ["MongoDB"]
    is_manual_connection           = false
    request_message                = "Please approve the private endpoint connection for Cosmos DB."
  }
  private_dns_zone_group {
    name                 = "example-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.private_dns_zone.id]
  }
}



