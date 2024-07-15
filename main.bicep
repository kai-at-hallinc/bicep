param location string = resourceGroup().location
param vnet_name string = 'ap-vnet-dev-85344'

resource sandbox_dev 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'ap-sandbox-dev-85344'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: '29d93db2-a75a-476d-abf1-afe5c87dcfff'
      }
    }
    displayName: 'sandbox_dev'
  }
}


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnet_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}
