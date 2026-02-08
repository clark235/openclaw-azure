# VM-Based Secure Tunnel

Cost-effective VM deployment for OpenClaw secure tunnel with private Azure OpenAI access.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Azure VNet (Private)                        │
│                                                                  │
│  ┌─────────────────┐         ┌─────────────────────────────────┐│
│  │  Ubuntu 24.04   │         │     Private DNS Zone            ││
│  │   Standard_B1ms │         │  privatelink.openai.azure.com   ││
│  │                 │         └────────────────┬────────────────┘│
│  │  ┌───────────┐  │                          │                 │
│  │  │ ClawLink  │  │    ┌─────────────┐   ┌───┴────────┐       │
│  │  │  Agent    │──┼───►│ Private     │───│ Azure      │       │
│  │  │ (Node.js) │  │    │ Endpoint    │   │ OpenAI     │       │
│  │  └─────┬─────┘  │    │ 10.0.2.x    │   │ (no public)│       │
│  │        │        │    └─────────────┘   └────────────┘       │
│  │   Port 8443     │                                            │
│  └────────┼────────┘                    ┌────────────────────┐  │
│           │                             │     Key Vault      │  │
│           │                             │  • tunnel-token    │  │
└───────────┼─────────────────────────────│  • openai-key      │──┘
            │ WebSocket (public)          └────────────────────┘
            ▼
     ┌──────────────┐
     │ Your Machine │  ← ClawLink client connects here
     │  (OpenClaw)  │
     └──────────────┘
```

## Features

- **~$15-22/mo** vs ~$70/mo for container approach
- **Zero public AI access** — OpenAI only reachable via private endpoint
- **Managed Identity** — VM auto-authenticates to Key Vault
- **Systemd service** — Auto-restart on failures
- **Cloud-init provisioning** — Fully automated setup

## Cost Breakdown

| Component | Monthly Cost |
|-----------|--------------|
| Standard_B1ms VM | ~$15 |
| Public IP (Standard) | ~$3 |
| Private Endpoint | ~$7 |
| Key Vault | ~$1 |
| **Total Base** | **~$26** |
| Azure OpenAI | Usage-based |

*Use Standard_B1ls (~$4/mo) for even lower costs if workload is light.*

## Quick Deploy

### Azure CLI

```bash
# Create resource group
az group create -n rg-clawlink-vm -l eastus2

# Deploy
az deployment group create \
  -g rg-clawlink-vm \
  -f azuredeploy.json \
  -p instanceName=myinstance \
  -p sshPublicKey="$(cat ~/.ssh/id_rsa.pub)"

# Get outputs
az deployment group show \
  -g rg-clawlink-vm \
  -n azuredeploy \
  --query properties.outputs
```

### One-Click Deploy

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fsecure-tunnel%2Fvm%2Fazuredeploy.json)

## After Deployment

1. **Get connection info** from deployment outputs:
   ```bash
   # Get tunnel endpoint and token
   az deployment group show -g rg-clawlink-vm -n azuredeploy \
     --query 'properties.outputs.clawlinkConfig.value' -o json
   ```

2. **Connect with ClawLink**:
   ```bash
   clawlink add myinstance --config '{"instance":{"endpoint":"ws://...","token":"..."}}'
   clawlink connect myinstance
   ```

3. **SSH for debugging** (if needed):
   ```bash
   ssh clawadmin@<fqdn>
   sudo journalctl -u clawlink-agent -f
   ```

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `instanceName` | Unique name (max 15 chars) | (required) |
| `location` | Azure region | Resource group location |
| `vmSize` | VM size | Standard_B1ms |
| `adminUsername` | SSH username | clawadmin |
| `sshPublicKey` | SSH public key | (required) |
| `openAiModel` | Model to deploy | gpt-4o-mini |
| `tunnelPort` | Agent port | 8443 |

## Troubleshooting

### Check agent status
```bash
ssh clawadmin@<fqdn>
sudo systemctl status clawlink-agent
sudo journalctl -u clawlink-agent -f
```

### Verify private endpoint
```bash
# From the VM
nslookup <instance>-ai.openai.azure.com
# Should resolve to 10.0.2.x (private IP)
```

### Restart agent
```bash
sudo systemctl restart clawlink-agent
```

## Security Notes

- SSH access is required for initial setup but can be removed via NSG rules after deployment
- Tunnel token is stored in Key Vault and injected via managed identity
- Azure OpenAI has no public network access — only accessible via private endpoint
- Consider adding IP restrictions to NSG for production use

## Comparison: VM vs Container

| Aspect | VM | Container (ACI) |
|--------|-----|-----------------|
| Monthly Cost | ~$22 | ~$70 |
| Startup Time | 2-3 min | 30-60 sec |
| Maintenance | OS updates needed | Managed |
| Flexibility | Full control | Limited |
| Cold Start | None | Possible |

Choose VM for cost savings, Container for managed simplicity.
