# main.tf
locals {
  asp_name = "asp-${var.app_service_name_specifier}-${random_pet.rg_name.id}"
  app_name = "app-${var.app_service_name_specifier}-${random_pet.rg_name.id}"
  cors_name = "https://${local.app_name}.azurewebsites.net"
  sa_name  = "sa${var.app_service_name_specifier}"
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

resource "azurerm_storage_account" "sa" {
  name                     = local.sa_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    cors_rule {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD", "POST", "OPTIONS", "MERGE", "PUT"]
      allowed_origins = ["${local.cors_name}"]
      exposed_headers = ["*"]
      max_age_in_seconds = 3600
    }
  }
  

  tags = {
    environment = "dev"
  }
}

# This is currently hard coded as upload in the code
# TODO: This should be a variable 
resource "azurerm_storage_container" "sac" {
  name                  = "upload"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
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

# TODO: When terraform changes this, it seems to remove basic auth for the ability to upload to SCM
# I need to determine what needs to be done to remedy that.
resource "azurerm_windows_web_app" "app" {
  name                = local.app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {

  }


  app_settings = {
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~2"
    "XDT_MicrosoftApplicationInsights_Mode"           = "default"
    "DiagnosticServices_EXTENSION_VERSION"            = "disabled"
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "disabled"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "disabled"
    "InstrumentationEngine_EXTENSION_VERSION"         = "disabled"
    "SnapshotDebugger_EXTENSION_VERSION"              = "disabled"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "disabled"
    "StorageAccountConnectionString"                  = azurerm_storage_account.sa.primary_connection_string
    "WEBSITE_WEBDEPLOY_USE_SCM"                       = "true"
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

