targetScope = 'subscription'

param virtualNetworkName string
param virtualNetworkAddressPrefix string

var policyDefinitionName = 'Allow-AB-series-VMs'
var policyAssignmentName = 'Allow-AB-series-VMs'
var resourceGroupName = 'networking-rg'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: policyDefinitionName
  properties: {
    policyType: 'Custom'
    mode: 'All'
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            not: {
              anyOf: [
                {
                  field: 'Microsoft.Compute/virtualMachines/sku.name'
                  like: 'Standard_A*'
                }
                {
                  field: 'Microsoft.Compute/virtualMachines/sku.name'
                  like: 'Standard_B*'
                }
              ]
            }
          }
        ]
      }
      then: {
        effect: 'Deny'
      }
    }
  }
}

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: policyAssignmentName
  properties: {
    policyDefinitionId: policyDefinition.id
  }
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: deployment().location
}

module virtualNetwork 'modules/virtualNetwork.bicep' = {
  scope: resourceGroup
  name: 'virtualNetwork'
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressPrefix: virtualNetworkAddressPrefix
  }
}
