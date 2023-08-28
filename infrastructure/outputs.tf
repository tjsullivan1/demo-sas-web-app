# outputs.tf
app_managed_identity = azurerm_windows_web_app.app.identity[0].principal_id
