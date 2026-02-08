# Secure Tunnel Deployment

Zero-trust deployment with mTLS tunnel, private endpoints, and no public ports.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Azure (Private)                          │
│  ┌───────────────┐    ┌──────────────┐    ┌────────────────────┐│
│  │ Tunnel Agent  │◄──►│ Azure OpenAI │    │ Key Vault          ││
│  │ (Container)   │    │ (Private EP) │    │ (Secrets + Certs)  ││
│  └───────┬───────┘    └──────────────┘    └────────────────────┘│
│          │ WebSocket (outbound only)                             │
└──────────┼──────────────────────────────────────────────────────┘
           │
           ▼
    ┌──────────────┐
    │ Your Machine │  ← OpenClaw connects here via tunnel client
    │ (OpenClaw)   │
    └──────────────┘
```

## Features

- **Zero public ports** — All traffic over outbound WebSocket
- **mTLS authentication** — Client certificates from Key Vault
- **Private Endpoints** — Azure OpenAI not exposed to internet
- **Secure by default** — VNet isolation for all resources

## One-Click Deploy

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fsecure-tunnel%2Fazuredeploy.json)

## What Gets Deployed

| Resource | Purpose |
|----------|---------|
| VNet + Subnets | Network isolation |
| Azure OpenAI | AI endpoint (private) |
| Private Endpoint | Secure OpenAI access |
| Key Vault | Secrets + mTLS certs |
| Container Instance | Tunnel agent |
| Container Registry | Agent image storage |

## Cost Estimate

| Component | Monthly |
|-----------|---------|
| Container Instance | ~$30 |
| Azure OpenAI | Usage-based |
| Key Vault | ~$1 |
| VNet/PE | ~$7 |
| **Total** | ~$38 + AI usage |

## Connecting Your OpenClaw

After deployment:

1. Get tunnel token from Key Vault:
   ```bash
   az keyvault secret show --vault-name <your-vault> --name tunnel-token --query value -o tsv
   ```

2. Connect OpenClaw via tunnel client (see [clawlink](https://github.com/clark235/clawlink))

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `instanceName` | Unique name for resources | (required) |
| `location` | Azure region | Resource group location |
| `openAiModel` | Model to deploy | gpt-4o-mini |
