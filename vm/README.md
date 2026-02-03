# OpenCLAW VM Deployment

Deploy OpenCLAW to an Azure Virtual Machine with full control and SSH access.

## Quick Start (Recommended)

Pre-configured with your messaging channel - bot connects automatically!

[![Deploy Quick Start](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fvm%2Fazuredeploy-quickstart.json)

## Basic Deployment

Deploy VM only, configure channels later via Control UI.

[![Deploy VM](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fvm%2Fazuredeploy.json)

---

## 💰 Detailed Cost Breakdown

### VM Compute Costs (Monthly)

| VM Size | vCPU | RAM | Pay-as-you-go | 1-Year Reserved | 3-Year Reserved |
|---------|------|-----|---------------|-----------------|-----------------|
| **Standard_B1ls** | 1 | 0.5 GB | ~$4 | ~$2.50 | ~$1.70 |
| **Standard_B1s** | 1 | 1 GB | ~$8 | ~$5 | ~$3.50 |
| **Standard_B1ms** ⭐ | 1 | 2 GB | ~$15 | ~$10 | ~$7 |
| **Standard_B2s** | 2 | 4 GB | ~$30 | ~$20 | ~$14 |
| **Standard_B2ms** | 2 | 8 GB | ~$60 | ~$40 | ~$28 |

⭐ **Recommended for personal use**

### Storage Costs (Monthly)

| Component | Size | Cost |
|-----------|------|------|
| OS Disk (Standard SSD) | 30 GB | ~$1.20 |
| OS Disk (Standard HDD) | 30 GB | ~$0.60 |

### Network Costs (Monthly)

| Component | Included | Overage |
|-----------|----------|---------|
| Public IP (Standard) | $0 | $0 |
| Outbound Data | 100 GB free | ~$0.05/GB after |

### Total Estimated Monthly Cost

| Configuration | Compute | Storage | Total |
|--------------|---------|---------|-------|
| **B1ms (Recommended)** | $15 | $1.20 | **~$16/mo** |
| B1s (Light use) | $8 | $1.20 | ~$9/mo |
| B2s (Heavy use) | $30 | $1.20 | ~$31/mo |

*Prices are estimates for US regions. Actual costs vary by region.*

---

## Features

✅ **Full SSH Access** - Connect and manage directly  
✅ **Persistent Storage** - Full disk, survives restarts  
✅ **systemd Service** - Auto-starts on boot  
✅ **Easy Updates** - `npm install -g clawdbot@latest`  
✅ **Full Control** - Install additional tools, customize freely  

---

## Files

| File | Description |
|------|-------------|
| `azuredeploy-quickstart.json` | Quick Start with channel config |
| `azuredeploy.json` | Basic VM deployment |
| `main.bicep` | Bicep template |
| `azuredeploy.parameters.json` | Example parameters |

---

## Parameters

### Quick Start Template

| Parameter | Required | Description |
|-----------|----------|-------------|
| `adminPasswordOrKey` | **Yes** | SSH public key |
| `messagingChannel` | No | `telegram`, `discord`, or `none` |
| `telegramBotToken` | If Telegram | Token from @BotFather |
| `discordBotToken` | If Discord | Token from Discord |
| `anthropicApiKey` | Recommended | API key |
| `vmSize` | No | Default: Standard_B1ms |

### Basic Template

| Parameter | Required | Description |
|-----------|----------|-------------|
| `adminPasswordOrKey` | **Yes** | SSH public key |
| `vmSize` | No | Default: Standard_B1ms |
| `adminUsername` | No | Default: clawdadmin |

---

## Post-Deployment

```bash
# SSH into your VM
ssh clawdadmin@<your-fqdn>

# View setup info & gateway token
cat ~/OPENCLAW_INFO.txt

# Check service status
sudo systemctl status openclaw

# View logs
sudo journalctl -u openclaw -f

# Restart service
sudo systemctl restart openclaw

# Update OpenCLAW
sudo npm install -g clawdbot@latest
sudo systemctl restart openclaw
```

---

## When to Choose VM

✅ **Choose VM if:**
- You want the lowest cost (~$16/mo vs ~$40/mo for container)
- You need SSH access for debugging/customization
- You're running 24/7 (personal assistant)
- You want to install additional tools

❌ **Consider Container if:**
- You prefer serverless/managed infrastructure
- You don't need SSH access
- You're okay with higher costs for less management

---

## Security Recommendations

1. **Restrict SSH**: After deployment, update NSG to allow SSH only from your IP
2. **Use SSH keys**: Never use password authentication
3. **Regular updates**: Keep OpenCLAW and system packages updated
4. **Firewall**: Consider using Tailscale for private access

```bash
# Restrict SSH to your IP only
az network nsg rule update \
  --resource-group <rg-name> \
  --nsg-name <vm-name>-nsg \
  --name SSH \
  --source-address-prefix "YOUR_IP/32"
```
