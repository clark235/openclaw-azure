# OpenCLAW Azure Deployment

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fazuredeploy.json)

One-click deployment of [OpenCLAW](https://github.com/clawdbot/clawdbot) (Clawdbot AI Assistant) to Azure.

## What is OpenCLAW?

OpenCLAW (Clawdbot) is an AI assistant that runs on your own infrastructure. It can connect to Discord, Telegram, WhatsApp, and more. Think of it as your personal AI that lives in your cloud.

- 🤖 AI-powered assistant using Claude, GPT, or other models
- 💬 Multi-channel: Discord, Telegram, WhatsApp, Signal, Slack
- 🔧 Extensible with skills and plugins
- 🔒 Self-hosted: your data stays on your server

## Quick Deploy

### Option 1: One-Click Deploy (Recommended)

Click the button above, or:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fazuredeploy.json)

### Option 2: Azure CLI

```bash
# Clone this repo
git clone https://github.com/clark235/openclaw-azure.git
cd openclaw-azure

# Create resource group
az group create --name openclaw-rg --location eastus

# Deploy (SSH key auth)
az deployment group create \
  --resource-group openclaw-rg \
  --template-file azuredeploy.json \
  --parameters adminPasswordOrKey="$(cat ~/.ssh/id_ed25519.pub)"
```

### Option 3: Bicep

```bash
az deployment group create \
  --resource-group openclaw-rg \
  --template-file main.bicep \
  --parameters adminPasswordOrKey="$(cat ~/.ssh/id_ed25519.pub)"
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `vmName` | `openclaw` | VM name |
| `location` | Resource group location | Azure region |
| `vmSize` | `Standard_B1ms` | VM size (see sizing below) |
| `adminUsername` | `clawdadmin` | SSH username |
| `authenticationType` | `sshPublicKey` | `sshPublicKey` or `password` |
| `adminPasswordOrKey` | *required* | SSH public key or password |
| `osDiskSizeGB` | `30` | OS disk size (30-256 GB) |

## VM Sizing Guide

| Size | vCPU | RAM | Monthly Cost* | Use Case |
|------|------|-----|--------------|----------|
| Standard_B1ls | 1 | 0.5 GB | ~$4 | Minimal (testing only) |
| Standard_B1s | 1 | 1 GB | ~$8 | Light use |
| **Standard_B1ms** | **1** | **2 GB** | **~$15** | **Recommended for personal use** |
| Standard_B2s | 2 | 4 GB | ~$30 | Multi-user / heavy workloads |
| Standard_B2ms | 2 | 8 GB | ~$60 | Power users |

*Costs are estimates and vary by region. Add ~$1-2/mo for storage.

## Deployment Outputs

After deployment completes, you'll receive:

| Output | Description |
|--------|-------------|
| `publicIPAddress` | VM's public IP |
| `fqdn` | DNS hostname |
| `sshCommand` | SSH command to connect |
| `controlUIUrl` | Clawdbot Control UI URL |
| `gatewayToken` | Auth token for Control UI |

## Post-Deployment Setup

### 1. Access the Control UI

Open the `controlUIUrl` from deployment outputs (e.g., `http://openclaw-xxxxx.eastus.cloudapp.azure.com:18789`)

### 2. Enter Gateway Token

Use the `gatewayToken` from deployment outputs to authenticate.

### 3. Configure API Keys

In the Control UI, add your AI provider API keys:
- **Anthropic**: Get key from [console.anthropic.com](https://console.anthropic.com)
- **OpenAI**: Get key from [platform.openai.com](https://platform.openai.com)

### 4. Add Channels (Optional)

Connect messaging platforms:
- **Discord**: Create bot at [discord.com/developers](https://discord.com/developers)
- **Telegram**: Create bot via [@BotFather](https://t.me/botfather)
- **WhatsApp**: Scan QR code in Control UI

## SSH Access

```bash
# Connect to your VM
ssh clawdadmin@<your-fqdn>

# View setup info
cat ~/OPENCLAW_INFO.txt

# Check service status
sudo systemctl status clawdbot

# View logs
sudo journalctl -u clawdbot -f

# Restart service
sudo systemctl restart clawdbot
```

## Updating Clawdbot

SSH into your VM and run:

```bash
sudo npm install -g clawdbot@latest
sudo systemctl restart clawdbot
```

## Security Recommendations

1. **Restrict SSH access**: Update NSG to allow SSH only from your IP
2. **Use SSH keys**: Avoid password authentication
3. **Enable Tailscale**: For private access without exposing ports
4. **Regular updates**: Keep Clawdbot and system packages updated

```bash
# Restrict SSH to your IP
az network nsg rule update \
  --resource-group openclaw-rg \
  --nsg-name openclaw-nsg \
  --name SSH \
  --source-address-prefix "YOUR_IP/32"
```

## Troubleshooting

### Gateway not accessible

1. Check if service is running: `sudo systemctl status clawdbot`
2. Check logs: `sudo journalctl -u clawdbot -n 50`
3. Verify NSG rules allow port 18789
4. Wait 2-3 minutes after deployment for setup to complete

### Setup script failed

Check the setup log:
```bash
sudo cat /var/log/openclaw-setup.log
```

### VM extension still running

The CustomScript extension can take 3-5 minutes. Check status:
```bash
az vm extension show \
  --resource-group openclaw-rg \
  --vm-name openclaw \
  --name OpenCLAWSetup \
  --query provisioningState
```

## Files

| File | Description |
|------|-------------|
| `azuredeploy.json` | ARM template (for Deploy button) |
| `main.bicep` | Bicep template (cleaner syntax) |
| `azuredeploy.parameters.json` | Example parameters file |

## Resources

- [Clawdbot Documentation](https://docs.clawd.bot)
- [Clawdbot GitHub](https://github.com/clawdbot/clawdbot)
- [Clawdbot Discord](https://discord.com/invite/clawd)

## License

MIT

---

Made with 🔧 by Clark
