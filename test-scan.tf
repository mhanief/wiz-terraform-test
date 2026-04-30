resource "azurerm_network_security_group" "wiz_test_nsg" {
  name                = "wiz-test-high-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name
}


resource "azurerm_network_security_rule" "wiz_test_allow_ssh" {
  # checkov:skip=CKV_AZURE_10
  name              = "allow-ssh-from-internet-test"
  priority          = 100
  direction         = "Inbound"
  access            = "Allow"
  protocol          = "Tcp"
  source_port_range = "*"
  # wiz-scan ignore-line
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.wiz_test_nsg.name
}


resource "azurerm_network_security_rule" "wiz_test_allow_rdp" {
  # checkov:skip=CKV_AZURE_9
  name              = "allow-rdp-from-internet-test"
  priority          = 110
  direction         = "Inbound"
  access            = "Allow"
  protocol          = "Tcp"
  source_port_range = "*"
  # wiz-scan ignore-line
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.wiz_test_nsg.name
}

locals {
  db_password = "MyProdDbPassword!2026"
  gh_pat           = "ghp_A1b2C3d4E5f6G7h8I9j0K1l2M3n4O5p6Q7r8"
  slack            = "xoxb-123456789012-123456789012-abcdefghijklmnopqrstuvwxyz12"
  aws_key          = "AKIA7H2K9Q4M8N5P2R1X"
  aws_secret       = "Qm9vZ2E1Nzd5S2xQb1N4Y0xVd2R3M2N2c0l5R2hKa1pY"
}


# wiz-scan ignore-block
resource "azurerm_container_group" "wiz_test_secrets_leak" {
  # checkov:skip=CKV2_AZURE_28
  # checkov:skip=CKV_AZURE_98
  # checkov:skip=CKV_AZURE_235
  # checkov:skip=CKV_AZURE_245
  name                = "wiz-test-container-secrets"
  location            = local.location
  resource_group_name = local.resource_group_name
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      "GITHUB_PAT"        = local.gh_pat
      "SLACK_TOKEN"       = local.slack
      "AWS_ACCESS_KEY_ID" = local.aws_key
      "AWS_SECRET_KEY"    = local.aws_secret
    }
  }
}

# wiz-scan ignore-block
resource "azurerm_postgresql_flexible_server" "wiz_test_db" {
  # checkov:skip=CKV_AZURE_136
  # checkov:skip=CKV2_AZURE_57
  # checkov:skip=CKV2_AZURE_28
  name                = "wiz-test-psql-server-12345"
  resource_group_name = local.resource_group_name
  location            = local.location
  version             = "13"

  administrator_login    = "psqladmin"
  administrator_password = local.db_password

  storage_mb = 32768
  sku_name   = "B_Standard_B1ms"
}
