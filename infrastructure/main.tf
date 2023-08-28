# main.tf
locals {
  asp_name = "asp-${var.app_service_name_specifier}-${random_pet.rg_name.id}"
  app_name = "app-${var.app_service_name_specifier}-${random_pet.rg_name.id}"
}

resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = var.resource_group_location

  # ignore changes to tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_service_plan" "asp" {
  name                = local.asp_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = var.app_service_sku_size
  os_type  = var.app_service_kind
  tags = {
    environment = "dev"
  }
}

resource "azurerm_windows_web_app" "app" {
  name                = local.app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_service_plan.asp.id


  app_settings = {
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~2"
    "XDT_MicrosoftApplicationInsights_Mode"           = "default"
    "DiagnosticServices_EXTENSION_VERSION"            = "disabled"
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "disabled"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "disabled"
    "InstrumentationEngine_EXTENSION_VERSION"         = "disabled"
    "SnapshotDebugger_EXTENSION_VERSION"              = "disabled"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "disabled"
  }

  identity {
    type = "SystemAssigned"
  }

  client_affinity_enabled = true
  https_only              = true

  tags = {
    environment = "dev"
  }
}