// OpenCLAW Azure Container Instance Deployment
// Serverless deployment - no VM management required
// https://github.com/clark235/openclaw-azure

@description('Name for the container instance')
@minLength(1)
@maxLength(63)
param containerName string = 'openclaw'

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('CPU cores (1 recommended for personal use)')
@allowed([1, 2, 4])
param cpuCores int = 1

@description('Memory in GB (2GB recommended for personal use)')
@allowed([2, 4, 8])
param memoryInGb int = 2

@description('Anthropic API key (can be configured later via Control UI)')
@secure()
param anthropicApiKey string = ''

@description('OpenAI API key (optional)')
@secure()
param openaiApiKey string = ''

@description('Discord bot token (optional)')
@secure()
param discordToken string = ''

@description('Telegram bot token (optional)')
@secure()
param telegramToken string = ''

// Variables
var imageUrl = 'node:22-bookworm-slim'
var dnsLabel = 'openclaw-${uniqueString(resourceGroup().id, containerName)}'
var storageAccountName = 'openclaw${uniqueString(resourceGroup().id)}'
var fileShareName = 'openclaw-data'
var gatewayToken = '${uniqueString(resourceGroup().id, containerName)}${uniqueString(subscription().subscriptionId, containerName)}'

// Storage Account for persistent data
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

// File Share for OpenCLAW data
resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: '${storageAccountName}/default/${fileShareName}'
  properties: {
    shareQuota: 5
  }
  dependsOn: [
    storageAccount
  ]
}

// Container Instance
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerName
  location: location
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: imageUrl
          command: [
            '/bin/sh'
            '-c'
            'echo "Installing OpenCLAW..." && npm install -g clawdbot && mkdir -p /data/.clawdbot /data/clawd && cat > /data/.clawdbot/clawdbot.json << \'EOF\'\n{"gateway":{"mode":"local","port":18789,"bind":"lan","auth":{"mode":"token","token":"${gatewayToken}"}},"agents":{"defaults":{"workspace":"/data/clawd"}}}\nEOF\necho "Starting OpenCLAW Gateway..." && clawdbot gateway'
          ]
          ports: [
            {
              port: 18789
              protocol: 'TCP'
            }
          ]
          environmentVariables: [
            {
              name: 'NODE_ENV'
              value: 'production'
            }
            {
              name: 'CLAWDBOT_STATE_DIR'
              value: '/data/.clawdbot'
            }
            {
              name: 'CLAWDBOT_WORKSPACE'
              value: '/data/clawd'
            }
            {
              name: 'ANTHROPIC_API_KEY'
              secureValue: anthropicApiKey
            }
            {
              name: 'OPENAI_API_KEY'
              secureValue: openaiApiKey
            }
            {
              name: 'DISCORD_TOKEN'
              secureValue: discordToken
            }
            {
              name: 'TELEGRAM_TOKEN'
              secureValue: telegramToken
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
          volumeMounts: [
            {
              name: 'data'
              mountPath: '/data'
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Always'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: 18789
          protocol: 'TCP'
        }
      ]
      dnsNameLabel: dnsLabel
    }
    volumes: [
      {
        name: 'data'
        azureFile: {
          shareName: fileShareName
          storageAccountName: storageAccountName
          storageAccountKey: storageAccount.listKeys().keys[0].value
        }
      }
    ]
  }
  dependsOn: [
    fileShare
  ]
}

// Outputs
output containerFqdn string = containerGroup.properties.ipAddress.fqdn
output containerIp string = containerGroup.properties.ipAddress.ip
output controlUIUrl string = 'http://${containerGroup.properties.ipAddress.fqdn}:18789'
output gatewayToken string = gatewayToken
