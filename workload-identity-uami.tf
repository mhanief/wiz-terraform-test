
locals {
  subscription_id     = "0d03b0f7-3e72-4cce-967e-63b75622c681"
  resource_group_name = "cse551-cam-sb-sec02-ue2-cluster"
  uami_name           = "cse551-cam-sb-sec02-ue2-wiz-wi-uami"
  oidc_issuer_url     = "https://eastus2.oic.prod-aks.azure.com/289321e0-9db6-4644-b371-956e6056d9eb/b929cc2e-69a0-400c-b71e-fdf35c77880b/"
  service_accounts    = ["wiz-wiz-sensor"] # SA name "{helm-release-name}-wiz-sensor"
  wiz_namespace       = "wiz-suite"
  location            = "eastus2"
  akv_name            = "cse551-iac-ue2-np-lpw"
  akv_rg_name         = "cse551-cybereng-np-eastus2"

}

terraform {
  cloud {
    organization = "DayforceCloud"
    workspaces {
      project = "cse-az-cse551"
      name    = "cse-az-cse551_wiz_uami_eastus2_sb_sec02"
    }
  }

  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  subscription_id = local.subscription_id
  features {
  }
}


resource "azurerm_user_assigned_identity" "wiz_kv_reader" {
  name                = local.uami_name
  resource_group_name = local.resource_group_name
  location            = local.location
}

resource "azurerm_federated_identity_credential" "aks_wi" {
  for_each = toset(local.service_accounts)

  name                = "aks-wi-${local.wiz_namespace}-${each.value}"
  resource_group_name = local.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = local.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.wiz_kv_reader.id
  subject             = "system:serviceaccount:${local.wiz_namespace}:${each.value}"
}

data "azurerm_key_vault" "wiz_kv" {
  name                = local.akv_name
  resource_group_name = local.akv_rg_name
}

resource "azurerm_role_assignment" "uami_kv_secrets_user" {
  scope                = data.azurerm_key_vault.wiz_kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.wiz_kv_reader.principal_id
}

output "uami_client_id" {
  value = azurerm_user_assigned_identity.wiz_kv_reader.client_id
}

output "uami_principal_id" {
  value = azurerm_user_assigned_identity.wiz_kv_reader.principal_id
}
