param appName string
param location string = resourceGroup().location
param sku string = 'Shared'
param skuCode string = 'D1'
param workerSize string = '0'
param workerSizeId string = '0'
param numberOfWorkers string = '1'
param currentStack string = 'dotnetcore'
param applicationInsightsName string = appName

var applicationInsightsName_var = applicationInsightsName
var hostingPlanName = appName

resource app 'Microsoft.Web/sites@2018-02-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    name: appName
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(applicationInsights.id, '2015-05-01').InstrumentationKey
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'default'
        }
        {
          name: 'DiagnosticServices_EXTENSION_VERSION'
          value: 'disabled'
        }
        {
          name: 'APPINSIGHTS_PROFILERFEATURE_VERSION'
          value: 'disabled'
        }
        {
          name: 'APPINSIGHTS_SNAPSHOTFEATURE_VERSION'
          value: 'disabled'
        }
        {
          name: 'InstrumentationEngine_EXTENSION_VERSION'
          value: 'disabled'
        }
        {
          name: 'SnapshotDebugger_EXTENSION_VERSION'
          value: 'disabled'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_BaseExtensions'
          value: 'disabled'
        }
      ]
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: currentStack
        }
      ]
    }
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: true
    httpsOnly: true
    alwaysOn: true
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: hostingPlanName
  location: location
  kind: ''
  properties: {
    name: hostingPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
  }
  sku: {
    tier: sku
    name: skuCode
  }
}

resource applicationInsights 'microsoft.insights/components@2015-05-01' = {
  name: applicationInsightsName_var
  location: location
  kind: 'web'
  properties: {
    ApplicationId: appName
    Application_Type: 'web'
  }
}

output miObjectId string = reference(app.id, '2019-08-01', 'full').identity.principalId