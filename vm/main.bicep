// OpenCLAW Azure Deployment
// Deploy OpenCLAW (Self-hosted AI Assistant) to Azure VM
// https://github.com/clark235/openclaw-azure

@description('Name for the virtual machine')
@minLength(1)
@maxLength(64)
param vmName string = 'openclaw'

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('VM size - B1ms (2GB RAM) recommended for personal use')
@allowed([
  'Standard_B1ls'
  'Standard_B1s'
  'Standard_B1ms'
  'Standard_B2s'
  'Standard_B2ms'
  'Standard_B2als_v2'
  'Standard_B2as_v2'
  'Standard_D2s_v3'
  'Standard_D2as_v4'
])
param vmSize string = 'Standard_B1ms'

@description('Admin username for SSH access')
param adminUsername string = 'clawdadmin'

@description('Authentication type - SSH key recommended')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('SSH public key or password')
@secure()
param adminPasswordOrKey string

@description('OS disk size in GB')
@minValue(30)
@maxValue(256)
param osDiskSizeGB int = 30

// Variables
var vnetName = '${vmName}-vnet'
var subnetName = 'default'
var nsgName = '${vmName}-nsg'
var publicIpName = '${vmName}-pip'
var nicName = '${vmName}-nic'
var dnsLabel = 'openclaw-${uniqueString(resourceGroup().id, vmName)}'
var gatewayToken = '${uniqueString(resourceGroup().id, vmName)}${uniqueString(subscription().subscriptionId, vmName)}'

var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

var setupScript = base64('''#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "[$(date)] Starting OpenCLAW setup..." | tee /var/log/openclaw-setup.log

# Install Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | bash - >> /var/log/openclaw-setup.log 2>&1
apt-get install -y nodejs >> /var/log/openclaw-setup.log 2>&1
echo "[$(date)] Node.js installed: $(node --version)" | tee -a /var/log/openclaw-setup.log

# Install OpenCLAW
npm install -g clawdbot >> /var/log/openclaw-setup.log 2>&1
echo "[$(date)] OpenCLAW installed: $(clawdbot --version)" | tee -a /var/log/openclaw-setup.log

# Create directories
mkdir -p /home/${adminUsername}/clawd
mkdir -p /home/${adminUsername}/.clawdbot

# Create config
cat > /home/${adminUsername}/.clawdbot/clawdbot.json << 'CONFIGEOF'
{
  "gateway": {
    "mode": "local",
    "port": 18789,
    "bind": "lan",
    "auth": {
      "mode": "token",
      "token": "${gatewayToken}"
    }
  },
  "agents": {
    "defaults": {
      "workspace": "/home/${adminUsername}/clawd"
    }
  }
}
CONFIGEOF

# Create systemd service
cat > /etc/systemd/system/openclaw.service << 'SERVICEEOF'
[Unit]
Description=OpenCLAW Gateway
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=${adminUsername}
WorkingDirectory=/home/${adminUsername}/clawd
Environment=NODE_ENV=production
ExecStart=/usr/bin/clawdbot gateway
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICEEOF

# Set permissions
chown -R ${adminUsername}:${adminUsername} /home/${adminUsername}/clawd
chown -R ${adminUsername}:${adminUsername} /home/${adminUsername}/.clawdbot
chmod 600 /home/${adminUsername}/.clawdbot/clawdbot.json

# Enable and start service
systemctl daemon-reload
systemctl enable openclaw
systemctl start openclaw

# Create info file
PUBLIC_IP=$(curl -s ifconfig.me)
cat > /home/${adminUsername}/OPENCLAW_INFO.txt << EOF
=====================================
  OpenCLAW Deployment Complete!
=====================================

Control UI: http://${PUBLIC_IP}:18789
Gateway Token: ${gatewayToken}

SSH: ssh ${adminUsername}@$(hostname -f)

Service Commands:
  sudo systemctl status openclaw
  sudo systemctl restart openclaw
  sudo journalctl -u openclaw -f

Update OpenCLAW:
  sudo npm install -g clawdbot@latest
  sudo systemctl restart openclaw

Docs: https://docs.clawd.bot
=====================================
EOF
chown ${adminUsername}:${adminUsername} /home/${adminUsername}/OPENCLAW_INFO.txt

echo "[$(date)] OpenCLAW setup complete!" | tee -a /var/log/openclaw-setup.log
''')

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'OpenCLAW-Gateway'
        properties: {
          priority: 1010
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '18789'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Public IP
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: dnsLabel
    }
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// Network Interface
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
  dependsOn: [
    vnet
  ]
}

// Virtual Machine
resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: authenticationType == 'password' ? adminPasswordOrKey : null
      linuxConfiguration: authenticationType == 'sshPublicKey' ? linuxConfiguration : null
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: osDiskSizeGB
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// Custom Script Extension
resource setupExtension 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  parent: vm
  name: 'OpenCLAWSetup'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      script: setupScript
    }
  }
}

// Outputs
output publicIPAddress string = publicIp.properties.ipAddress
output fqdn string = publicIp.properties.dnsSettings.fqdn
output sshCommand string = 'ssh ${adminUsername}@${publicIp.properties.dnsSettings.fqdn}'
output controlUIUrl string = 'http://${publicIp.properties.dnsSettings.fqdn}:18789'
output gatewayToken string = gatewayToken
