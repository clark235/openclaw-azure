# OpenCLAW Azure Deployment

One-click deployment of [OpenCLAW](https://github.com/clawdbot/clawdbot) to Azure.

## Deployment Options

### Option 1: Virtual Machine (Recommended)

Full VM with SSH access, persistent storage, and auto-start on boot.

[![Deploy VM to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fazuredeploy.json)

**Best for:** Personal use, development, full control

| Size | vCPU | RAM | Monthly Cost* |
|------|------|-----|--------------|
| Standard_B1ms | 1 | 2 GB | ~$15 |
| Standard_B2s | 2 | 4 GB | ~$30 |

### Option 2: Container Instance (Serverless)

Serverless container - no VM to manage, pay only for what you use.

[![Deploy Container to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fazuredeploy-container.json)

**Best for:** Quick testing, serverless preference, minimal management

| Config | vCPU | RAM | Monthly Cost* |
|--------|------|-----|--------------|
| Default | 1 | 2 GB | ~$35-45 |
| Medium | 2 | 4 GB | ~$70-90 |

*Costs vary by region. VM includes ~$1-2/mo storage.

---

## What is OpenCLAW?

OpenCLAW is an open-source AI assistant that runs on your own infrastructure.

- 🤖 AI-powered assistant using Claude, GPT, or other models
- 💬 Multi-channel: Discord, Telegram, WhatsApp, Signal, Slack
- 🔧 Extensible with skills and plugins
- 🔒 Self-hosted: your data stays on your server

---

## Quick Start

### VM Deployment (CLI)

```bash
# Clone this repo
git clone https://github.com/clark235/openclaw-azure.git
cd openclaw-azure

# Create resource group
az group create --name openclaw-rg --location eastus

# Deploy VM
az deployment group create \
  --resource-group openclaw-rg \
  --template-file azuredeploy.json \
  --parameters adminPasswordOrKey="$(cat ~/.ssh/id_ed25519.pub)"
```

### Container Deployment (CLI)

```bash
# Deploy container (API keys optional - can configure later)
az deployment group create \
  --resource-group openclaw-rg \
  --template-file azuredeploy-container.json
```

---

## VM Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `vmName` | `openclaw` | VM name |
| `location` | Resource group location | Azure region |
| `vmSize` | `Standard_B1ms` | VM size |
| `adminUsername` | `clawdadmin` | SSH username |
| `authenticationType` | `sshPublicKey` | `sshPublicKey` or `password` |
| `adminPasswordOrKey` | *required* | SSH public key or password |

## Container Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `containerName` | `openclaw` | Container name |
| `location` | Resource group location | Azure region |
| `cpuCores` | `1` | CPU cores (1, 2, or 4) |
| `memoryInGb` | `2` | Memory in GB (2, 4, or 8) |
| `anthropicApiKey` | *optional* | Anthropic API key |
| `discordToken` | *optional* | Discord bot token |

---

## Post-Deployment Setup

### 1. Access the Control UI

After deployment completes, open the `controlUIUrl` from outputs:
- VM: `http://openclaw-xxxxx.eastus.cloudapp.azure.com:18789`
- Container: `http://openclaw-xxxxx.eastus.azurecontainer.io:18789`

### 2. Enter Gateway Token

Use the `gatewayToken` from deployment outputs to authenticate.

### 3. Configure API Keys

In the Control UI, add your AI provider API keys:
- **Anthropic**: [console.anthropic.com](https://console.anthropic.com)
- **OpenAI**: [platform.openai.com](https://platform.openai.com)

### 4. Add Channels (Optional)

- **Discord**: Create bot at [discord.com/developers](https://discord.com/developers)
- **Telegram**: Create bot via [@BotFather](https://t.me/botfather)
- **WhatsApp**: Scan QR code in Control UI

---

## VM Management

```bash
# SSH into VM
ssh clawdadmin@<your-fqdn>

# View setup info
cat ~/OPENCLAW_INFO.txt

# Check service
sudo systemctl status openclaw

# View logs
sudo journalctl -u openclaw -f

# Restart
sudo systemctl restart openclaw

# Update OpenCLAW
sudo npm install -g clawdbot@latest
sudo systemctl restart openclaw
```

---

## Container Management

```bash
# View container logs
az container logs --resource-group openclaw-rg --name openclaw

# Restart container
az container restart --resource-group openclaw-rg --name openclaw

# Delete and redeploy to update
az container delete --resource-group openclaw-rg --name openclaw --yes
az deployment group create --resource-group openclaw-rg --template-file azuredeploy-container.json
```

---

## VM vs Container: Which to Choose?

| Feature | VM | Container |
|---------|----|-----------| 
| **SSH Access** | ✅ Yes | ❌ No |
| **Persistent Storage** | ✅ Full disk | ✅ Azure Files |
| **Auto-restart** | ✅ systemd | ✅ Always restart |
| **Management** | More control | Less maintenance |
| **Cost (2GB)** | ~$15/mo | ~$35-45/mo |
| **Boot Time** | ~2-3 min | ~3-5 min |
| **Best For** | Production, dev | Testing, serverless |

**Recommendation:** Use **VM** for production/daily use (cheaper, more control). Use **Container** for quick testing or if you prefer serverless.

---

## Troubleshooting

### Gateway not accessible

1. Wait 3-5 minutes after deployment for setup to complete
2. Check deployment outputs for correct URL
3. Verify NSG/firewall allows port 18789

### VM: Check service status

```bash
ssh clawdadmin@<fqdn>
sudo systemctl status openclaw
sudo journalctl -u openclaw -n 50
sudo cat /var/log/openclaw-setup.log
```

### Container: Check logs

```bash
az container logs --resource-group openclaw-rg --name openclaw --follow
```

---

## Files

| File | Description |
|------|-------------|
| `azuredeploy.json` | VM ARM template |
| `azuredeploy-container.json` | Container ARM template |
| `main.bicep` | VM Bicep template |
| `container.bicep` | Container Bicep template |

---

## Security Recommendations

1. **Restrict access**: Update NSG to allow only your IP
2. **Use SSH keys**: For VM, avoid password authentication  
3. **Enable Tailscale**: For private access without exposing ports
4. **Regular updates**: Keep OpenCLAW updated

---

## Resources

- [OpenCLAW Documentation](https://docs.clawd.bot)
- [OpenCLAW GitHub](https://github.com/clawdbot/clawdbot)
- [OpenCLAW Discord](https://discord.com/invite/clawd)

## License

MIT

---

Made with 🔧 by Clark
