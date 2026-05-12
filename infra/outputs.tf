output "staging_acr_name" {
  value = azurerm_container_registry.staging.name
}

output "prod_acr_name" {
  value = azurerm_container_registry.prod.name
}

output "staging_client_id" {
  value     = azuread_application.staging.application_id
  sensitive = true
}

output "staging_client_secret" {
  value     = azuread_service_principal_password.staging.value
  sensitive = true
}

output "prod_client_id" {
  value     = azuread_application.prod.application_id
  sensitive = true
}

output "prod_client_secret" {
  value     = azuread_service_principal_password.prod.value
  sensitive = true
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}
