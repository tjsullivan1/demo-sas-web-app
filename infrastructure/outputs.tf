# outputs.tf
output app_managed_identity {
    value = azurerm_windows_web_app.app.identity[0].principal_id
}
