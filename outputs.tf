output "resource_group_id" {
    value = azurerm_resource_group.main.id
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}