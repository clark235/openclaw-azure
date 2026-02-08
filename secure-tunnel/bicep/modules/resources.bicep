// OpenClaw Resources Module
// Contains: AI Foundry, VNet, Private Endpoint, Key Vault

@description('Location for all resources')
param location string

@description('Azure OpenAI resource name')
param openAiName string

@description('VNet name')
param vnetName string

@description('Key Vault name')
param keyVaultName string

@description('Resource tags')
param tags object

// Virtual Network with subnets
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'container-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'private-endpoints'
        properties: {
          addressPrefix: '10.0.2.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// Azure OpenAI (AI Foundry)
resource openAi 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: openAiName
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: openAiName
    publicNetworkAccess: 'Enabled'
  }
}

// GPT-4o-mini model deployment
resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: openAi
  name: 'gpt-4o-mini'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o-mini'
      version: '2024-07-18'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
  }
}

// Private Endpoint for Azure OpenAI
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: '${openAiName}-pe'
  location: location
  properties: {
    subnet: {
      id: vnet.properties.subnets[1].id
    }
    privateLinkServiceConnections: [
      {
        name: '${openAiName}-connection'
        properties: {
          privateLinkServiceId: openAi.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
  }
}

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    accessPolicies: []
  }
}

// Outputs
output aiFoundryEndpoint string = openAi.properties.endpoint
output modelDeploymentName string = modelDeployment.name
output vnetResourceId string = vnet.id
output keyVaultUrl string = keyVault.properties.vaultUri
output privateEndpointIp string = privateEndpoint.properties.customDnsConfigs[0].ipAddresses[0]
