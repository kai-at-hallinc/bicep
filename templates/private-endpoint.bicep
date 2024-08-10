param storageAccountPrefix string = 'hallinc-storage-'
param vnetName string = 'hallinc-vnet'
param vnetAddressPrefix string = '10.0.0.0/16'
param privateSubnetName string = 'hallinc-storage-subnet'
param privateSubnetAddressPrefix string = '10.0.1.0/24'
param privateEndpointName string = 'hallinc-private-endpoint'
param storageLinkName string = 'hallinc-storage-link'
param databaseLinkName string = 'hallinc-sql-link'

var storageDnsZoneName = environment().suffixes.storage
var databaseDnsZoneName = environment().suffixes.sqlServerHostname
var dnsZoneGroupName = 'hallinc-dns-zone'
var location = resourceGroup().location
var storageAccountName = toLower('${storageAccountPrefix}${uniqueString(resourceGroup().id)}')
var RootContainerName = '${storageAccountName}/default/datalake'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    networkAcls: {
      bypass: 'AzureServices, Logging, Metrics'
      defaultAction: 'Deny'
    }
    isHnsEnabled: true
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: RootContainerName
  properties: {
    publicAccess: 'None'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: privateSubnetName
        properties: {
          addressPrefix: privateSubnetAddressPrefix
        }
      }
    ]
  }
}

resource storageEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: storageLinkName
        properties: {
          privateLinkServiceId: resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
          groupIds: [
            'blob'
          ]
        }
      }
      {
        name: databaseLinkName
        properties: {
          privateLinkServiceId: resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, privateSubnetName)
    }
  }
}

resource storageDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: storageDnsZoneName
  location: 'global'
}

resource databaseDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: databaseDnsZoneName
  location: 'global'
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: dnsZoneGroupName
  parent: storageEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'storageConfig'
        properties: {
          privateDnsZoneId: storageDnsZone.id
        }
      }
      {
        name: 'databaseConfig'
        properties: {
          privateDnsZoneId: databaseDnsZone.id
        }
      }
    ]
  }
}
