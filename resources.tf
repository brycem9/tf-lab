data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_storage_account" "main" {
  #checkov:skip=CKV2_AZURE_33:No private endpoint in the lab; would use one in production
  #checkov:skip=CKV2_AZURE_40:Shared key left on for the lab; would use Entra ID auth in production
  #checkov:skip=CKV2_AZURE_41:No SAS tokens are used
  #checkov:skip=CKV_AZURE_206:LRS is enough for throwaway data
  #checkov:skip=CKV_AZURE_59:Reviewed; public access to blobs is already disabled
  #checkov:skip=CKV_AZURE_33:No queues are used
  name                            = "st${var.environment}${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_key_vault" "main" {
  #checkov:skip=CKV_AZURE_110:Purge protection off so the lab can be fully destroyed
  #checkov:skip=CKV_AZURE_42:Same reason as above
  name                       = "kv-${var.environment}-${random_string.suffix.result}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  tags                       = local.common_tags
}

resource "azurerm_role_assignment" "me_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "demo" {
  name            = "demo-secret"
  value           = "not-a-real-secret"
  key_vault_id    = azurerm_key_vault.main.id
  content_type    = "text/plain"
  expiration_date = "2027-01-01T00:00:00Z"

  depends_on = [azurerm_role_assignment.me_secrets_officer]
}