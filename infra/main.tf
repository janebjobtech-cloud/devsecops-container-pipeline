terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-container-pipeline-${var.yourname}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_registry" "staging" {
  name                = "acrstaging${var.yourname}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

resource "azurerm_container_registry" "prod" {
  name                = "acrprod${var.yourname}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

resource "azuread_application" "staging" {
  display_name = "sp-acr-staging-${var.yourname}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "staging" {
  application_id               = azuread_application.staging.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "staging" {
  service_principal_id = azuread_service_principal.staging.object_id
  rotate_when_changed  = { rotation_id = "v1" }
}

resource "azurerm_role_assignment" "staging_push" {
  scope                = azurerm_container_registry.staging.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.staging.object_id
}

resource "azurerm_role_assignment" "staging_pull" {
  scope                = azurerm_container_registry.staging.id
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.staging.object_id
}

resource "azuread_application" "prod" {
  display_name = "sp-acr-prod-${var.yourname}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "prod" {
  application_id               = azuread_application.prod.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "prod" {
  service_principal_id = azuread_service_principal.prod.object_id
  rotate_when_changed  = { rotation_id = "v1" }
}

resource "azurerm_role_assignment" "prod_push" {
  scope                = azurerm_container_registry.prod.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.prod.object_id
}

resource "azurerm_role_assignment" "prod_staging_pull" {
  scope                = azurerm_container_registry.staging.id
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.prod.object_id
}
