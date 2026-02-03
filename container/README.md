# OpenCLAW Container Deployment

Deploy OpenCLAW to Azure Container Instances - serverless, no VM to manage.

[![Deploy Container](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fcontainer%2Fazuredeploy.json)

---

## 💰 Detailed Cost Breakdown

### Container Compute Costs (Monthly)

Azure Container Instances charges per-second for vCPU and memory.

| Configuration | vCPU | RAM | Hourly | Monthly (24/7) |
|--------------|------|-----|--------|----------------|
| **Minimal** | 1 | 1 GB | ~$0.035 | ~$26 |
| **Default** ⭐ | 1 | 2 GB | ~$0.048 | ~$35 |
| **Medium** | 2 | 4 GB | ~$0.096 | ~$70 |
| **Large** | 4 | 8 GB | ~$0.192 | ~$140 |

⭐ **Recommended configuration**

### Pricing Formula

```
Monthly Cost = (vCPU × $0.035/hr + Memory GB × $0.0035/hr) × 730 hours
```

| Component | Per Hour | Per Month (730 hrs) |
|-----------|----------|---------------------|
| 1 vCPU | $0.035 | $25.55 |
| 1 GB Memory | $0.0035 | $2.56 |

**Example: 1 vCPU + 2 GB = $25.55 + $5.11 = ~$31/mo** (+ storage)

### Storage Costs (Monthly)

| Component | Size | Cost |
|-----------|------|------|
| Azure Files (Standard) | 5 GB | ~$0.30 |
| Azure Files (Premium) | 5 GB | ~$0.75 |
| Storage Account | - | ~$0.02 |

### Network Costs

| Component | Cost |
|-----------|------|
| Public IP | Included |
| Outbound Data (first 100GB) | Free |
| Outbound Data (after 100GB) | ~$0.05/GB |

### Total Estimated Monthly Cost

| Configuration | Compute | Storage | Total |
|--------------|---------|---------|-------|
| 1 vCPU / 1 GB | $26 | $0.50 | **~$27/mo** |
| **1 vCPU / 2 GB** ⭐ | $31 | $0.50 | **~$32/mo** |
| 2 vCPU / 4 GB | $62 | $0.50 | ~$63/mo |

*Prices are estimates for US regions. Actual costs vary by region.*

---

## ⚠️ Cost Comparison: VM vs Container

| | VM (B1ms) | Container (1 vCPU/2GB) |
|--|-----------|------------------------|
| **Monthly Cost** | **~$16** | ~$32 |
| Compute | $15 | $31 |
| Storage | $1.20 | $0.50 |
| **Savings** | **50% cheaper** | - |

**Recommendation:** For 24/7 personal use, VM is significantly cheaper. Use containers for testing or if you strongly prefer serverless.

---

## Features

✅ **Serverless** - No VM to manage  
✅ **Auto-restart** - Container restarts on failure  
✅ **Persistent Storage** - Azure Files for data  
✅ **Fast Deployment** - ~3-5 minutes  
❌ **No SSH Access** - Can only view logs via Azure CLI  
❌ **Limited Control** - Can't install additional tools  

---

## Files

| File | Description |
|------|-------------|
| `azuredeploy.json` | ARM template |
| `main.bicep` | Bicep template |

---

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `containerName` | No | openclaw | Container name |
| `location` | No | Resource group | Azure region |
| `cpuCores` | No | 1 | CPU cores (1, 2, or 4) |
| `memoryInGb` | No | 2 | Memory in GB (2, 4, or 8) |
| `anthropicApiKey` | No | - | Anthropic API key |
| `openaiApiKey` | No | - | OpenAI API key |
| `discordToken` | No | - | Discord bot token |
| `telegramToken` | No | - | Telegram bot token |

---

## Post-Deployment

### View Logs
```bash
# Stream logs
az container logs \
  --resource-group <rg-name> \
  --name openclaw \
  --follow

# View recent logs
az container logs \
  --resource-group <rg-name> \
  --name openclaw
```

### Restart Container
```bash
az container restart \
  --resource-group <rg-name> \
  --name openclaw
```

### Update OpenCLAW
```bash
# Delete and redeploy (containers pull latest on start)
az container delete --resource-group <rg-name> --name openclaw --yes
az deployment group create \
  --resource-group <rg-name> \
  --template-file azuredeploy.json
```

### View Container Status
```bash
az container show \
  --resource-group <rg-name> \
  --name openclaw \
  --query "{Status:instanceView.state, IP:ipAddress.ip, FQDN:ipAddress.fqdn}"
```

---

## When to Choose Container

✅ **Choose Container if:**
- You prefer serverless/managed infrastructure
- You don't need SSH access
- You're testing or evaluating OpenCLAW
- Cost is not a primary concern

❌ **Consider VM if:**
- You want the lowest cost (50% cheaper)
- You need SSH access for debugging
- You want to install additional tools
- You're running 24/7 as a personal assistant

---

## Limitations

1. **No SSH access** - Can't shell into the container
2. **No custom tools** - Can't install additional packages
3. **Restart = reinstall** - Container reinstalls OpenCLAW on each restart
4. **Higher cost** - ~2x more expensive than equivalent VM

---

## Architecture

```
┌─────────────────────────────────────────┐
│         Azure Container Instance        │
│  ┌───────────────────────────────────┐  │
│  │        OpenCLAW Gateway           │  │
│  │    (clawdbot on Node.js 22)       │  │
│  └───────────────────────────────────┘  │
│                   │                     │
│                   ▼                     │
│  ┌───────────────────────────────────┐  │
│  │     Azure Files (Persistent)      │  │
│  │  /data/.clawdbot (config)         │  │
│  │  /data/clawd (workspace)          │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
              │
              ▼ Port 18789
        Control UI + API
```
