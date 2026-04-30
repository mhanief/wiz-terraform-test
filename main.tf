provider "azurerm" {
  features {}

  skip_provider_registration = true
}

resource "azurerm_resource_group" "wiz_test_rg" {
  name     = "wiz-test-rg"
  location = "East US"
}

# 🚨 Public Storage Account (HIGH severity)
resource "azurerm_storage_account" "wiz_test_storage" {
  name                     = "wizteststorage12345"
  resource_group_name      = azurerm_resource_group.wiz_test_rg.name
  location                 = azurerm_resource_group.wiz_test_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = true
}

# 🚨 NSG open to the world (HIGH severity)
resource "azurerm_network_security_group" "wiz_test_nsg" {
  name                = "wiz-test-nsg"
  location            = azurerm_resource_group.wiz_test_rg.location
  resource_group_name = azurerm_resource_group.wiz_test_rg.name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh-from-internet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.wiz_test_rg.name
  network_security_group_name = azurerm_network_security_group.wiz_test_nsg.name
}
