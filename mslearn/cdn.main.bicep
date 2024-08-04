@description('The Azure region into which the resources should be deployed.')
param location string = 'northeurope'

@description('The name of the App Service app.')
param appServiceAppName string = 'hallinc-${uniqueString(resourceGroup().id)}'

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string = 'F1'

var appServicePlanName = 'hallinc-app-plan'

@description('Indicates whether a CDN should be deployed.')
param deployCdn bool = true

module app 'modules/app.bicep' = {
  name: 'hallinc-app'
  params: {
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    location: location
  }
}

module cdn 'modules/cdn.bicep' = if (deployCdn) {
  name: 'hallinc-cdn'
  params: {
    httpsOnly: true
    originHostName: app.outputs.appServiceAppHostName
  }
}

@description('The host name to use to access the website.')
output websiteHostName string = deployCdn ? cdn.outputs.endpointHostName : app.outputs.appServiceAppHostName
