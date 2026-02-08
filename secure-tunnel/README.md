# Secure Tunnel Deployment

Zero-trust deployment with mTLS tunnel, private endpoints, and no public AI ports.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Azure (Private)                          │
│  ┌───────────────┐    ┌──────────────┐    ┌────────────────────┐│
│  │ Tunnel Agent  │◄──►│ Azure OpenAI │    │ Key Vault          ││
│  │ (VM or ACI)   │    │ (Private EP) │    │ (Secrets + Certs)  ││
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

## Deployment Options

| Option | Monthly Cost | Best For |
|--------|--------------|----------|
| **[VM-based](vm/)** | ~$22 | Cost-sensitive, full control |
| **[Container-based](.)** | ~$70 | Managed, faster startup |

## Features

- **Zero public ports** — All traffic over outbound WebSocket
- **mTLS authentication** — Client certificates from Key Vault
- **Private Endpoints** — Azure OpenAI not exposed to internet
- **Secure by default** — VNet isolation for all resources

---

## Option 1: VM-Based (~$22/mo) ⭐ Recommended

**[Full documentation →](vm/README.md)**

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fsecure-tunnel%2Fvm%2Fazuredeploy.json)

```bash
az deployment group create \
  -g rg-clawlink \
  -f vm/azuredeploy.json \
  -p instanceName=myinstance \
  -p sshPublicKey="$(cat ~/.ssh/id_rsa.pub)"
```

**Cost breakdown:**
- Standard_B1ms VM: ~$15
- Public IP + Private Endpoint: ~$10
- Key Vault: ~$1

---

## Option 2: Container-Based (~$70/mo)

Uses Azure Container Instances with Container Registry.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fsecure-tunnel%2Fazuredeploy.json)

**Cost breakdown:**
- Container Instance: ~$30
- Container Registry: ~$30
- VNet/Private Endpoint: ~$7
- Key Vault: ~$1

---

## Connecting Your OpenClaw

After deployment (either option):

1. Get tunnel config from deployment outputs:
   ```bash
   az deployment group show -g <rg-name> -n azuredeploy \
     --query 'properties.outputs.clawlinkConfig.value' -o json
   ```

2. Connect with [ClawLink](https://github.com/clark235/clawlink):
   ```bash
   clawlink add myinstance --config '{"instance":{...}}'
   clawlink connect myinstance
   ```

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `instanceName` | Unique name for resources | (required) |
| `location` | Azure region | Resource group location |
| `openAiModel` | Model to deploy | gpt-4o-mini |

See individual option READMEs for full parameter lists.

## Security Architecture

```
Internet                    │         Azure Private VNet
                            │
┌──────────────┐            │    ┌───────────────────────────────┐
│ Your Machine │            │    │                               │
│              │  WebSocket │    │  ┌─────────┐   ┌───────────┐  │
│ ┌──────────┐ │  (port    │────┼──│ Tunnel  │───│ Private   │  │
│ │ ClawLink │─┼──8443)────┼────┼──│ Agent   │   │ Endpoint  │  │
│ │ Client   │ │            │    │  └─────────┘   └─────┬─────┘  │
│ └──────────┘ │            │    │                      │        │
└──────────────┘            │    │              ┌───────▼──────┐ │
                            │    │              │ Azure OpenAI │ │
                            │    │              │ (no public)  │ │
                            │    │              └──────────────┘ │
                            │    └───────────────────────────────┘
```

**Key security properties:**
- Azure OpenAI has `publicNetworkAccess: Disabled`
- Only the tunnel agent (inside VNet) can reach OpenAI
- Tunnel token authenticates client connections
- mTLS optional for additional client verification
