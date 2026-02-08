// OpenClaw Azure Infrastructure - Main Bicep Template
// Deploys AI Foundry, VNet, Private Endpoint, and Key Vault

targetScope = 'subscription'

@description('Location for all resources')
param location string = 'southcentralus'

@description('Resource group name')
param resourceGroupName string = 'rg-openclaw-test'

@description('Azure OpenAI resource name')
param openAiName string = 'openclaw-ai-foundry'

@description('VNet name')
param vnetName string = 'openclaw-vnet'

@description('Key Vault name')
param keyVaultName string = 'kv-openclaw-test'

// Common tags
var tags = {
  owner: 'clark'
  project: 'secure-openclaw'
  purpose: 'OpenClaw AI infrastructure'
  temporary: 'true'
}

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Deploy all resources
module resources 'modules/resources.bicep' = {
  scope: rg
  name: 'resources-deployment'
  params: {
    location: location
    openAiName: openAiName
    vnetName: vnetName
    keyVaultName: keyVaultName
    tags: tags
  }
}

// Outputs
output aiFoundryEndpoint string = resources.outputs.aiFoundryEndpoint
output modelDeploymentName string = resources.outputs.modelDeploymentName
output vnetResourceId string = resources.outputs.vnetResourceId
output keyVaultUrl string = resources.outputs.keyVaultUrl
output privateEndpointIp string = resources.outputs.privateEndpointIp
