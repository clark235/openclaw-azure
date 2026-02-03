# OpenCLAW VM Deployment

Deploy OpenCLAW to an Azure Virtual Machine with full control and SSH access.

## 🚀 Ultimate Deployment (NEW!)

Choose your AI provider AND messaging channel - fully configured and ready to chat!

[![Deploy Ultimate](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fvm%2Fazuredeploy-ultimate.json)

### Supported AI Providers

| Provider | Model Examples | Get API Key |
|----------|---------------|-------------|
| **Anthropic** ⭐ | Claude Opus, Sonnet, Haiku | [console.anthropic.com](https://console.anthropic.com) |
| **OpenAI** | GPT-4o, GPT-4, GPT-3.5 | [platform.openai.com](https://platform.openai.com) |
| **Azure OpenAI** | GPT-4o, GPT-4 (your Azure resource) | [Azure Portal](https://portal.azure.com) |
| **OpenRouter** | 100+ models via single API | [openrouter.ai](https://openrouter.ai) |
| **Google** | Gemini Pro, Gemini Flash | [aistudio.google.com](https://aistudio.google.com) |
| **Groq** | Llama 3.3 70B (fast!) | [console.groq.com](https://console.groq.com) |
| **Mistral** | Mistral Large, Medium | [console.mistral.ai](https://console.mistral.ai) |
| **xAI** | Grok-3 | [x.ai](https://x.ai) |

⭐ **Recommended:** Anthropic Claude for best reasoning, Groq for fastest responses

### Azure OpenAI Integration

Two options for Azure OpenAI:

1. **Use existing Azure OpenAI resource:**
   - Enter your endpoint URL
   - Enter your deployment name
   - Enter your API key

2. **Deploy new Azure OpenAI resource:**
   - Check "Deploy Azure OpenAI" 
   - Template creates the resource for you
   - ⚠️ Requires [Azure OpenAI access approval](https://aka.ms/oai/access)

---

## Other Deployment Options

### Quick Start (Pre-configured Channel)

[![Deploy Quick Start](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fvm%2Fazuredeploy-quickstart.json)

### Basic (Configure Later)

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

### Total Estimated Monthly Cost

| Configuration | Compute | Storage | **Total** |
|--------------|---------|---------|-----------|
| **B1ms (Recommended)** | $15 | $1.20 | **~$16/mo** |
| B1s (Light use) | $8 | $1.20 | ~$9/mo |
| B2s (Heavy use) | $30 | $1.20 | ~$31/mo |

*Prices are estimates for US regions. AI API usage billed separately by provider.*

### AI Provider Costs (Separate)

| Provider | Pricing Model | Estimate (casual use) |
|----------|--------------|----------------------|
| Anthropic Claude | Per token | ~$5-20/mo |
| OpenAI GPT-4o | Per token | ~$5-20/mo |
| Azure OpenAI | Per token | ~$5-20/mo |
| OpenRouter | Per token (varies) | ~$5-20/mo |
| Groq | Free tier available | $0-10/mo |
| Google Gemini | Free tier available | $0-10/mo |

---

## Files

| File | Description |
|------|-------------|
| `azuredeploy-ultimate.json` | **Ultimate** - AI provider + channel selection |
| `azuredeploy-quickstart.json` | Quick Start - channel only |
| `azuredeploy.json` | Basic VM deployment |
| `main.bicep` | Bicep template |

---

## Ultimate Template Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `adminPasswordOrKey` | **Yes** | SSH public key |
| `aiProvider` | No | AI provider (default: anthropic) |
| `aiApiKey` | Recommended | API key for chosen provider |
| `azureOpenAiEndpoint` | If Azure | Your Azure OpenAI endpoint URL |
| `azureOpenAiDeploymentName` | If Azure | Deployment name (e.g., gpt-4o) |
| `deployAzureOpenAI` | No | Create new Azure OpenAI resource |
| `messagingChannel` | No | telegram, discord, or none |
| `telegramBotToken` | If Telegram | Token from @BotFather |
| `discordBotToken` | If Discord | Token from Discord |

---

## Getting API Keys

### Anthropic (Claude) - Recommended
1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Sign up / Sign in
3. Go to API Keys → Create Key
4. Copy the key (starts with `sk-ant-`)

### OpenAI (GPT)
1. Go to [platform.openai.com](https://platform.openai.com)
2. Sign up / Sign in
3. Go to API Keys → Create new secret key
4. Copy the key (starts with `sk-`)

### Azure OpenAI
1. Go to [Azure Portal](https://portal.azure.com)
2. Create or open Azure OpenAI resource
3. Go to Keys and Endpoint
4. Copy Key 1 and Endpoint URL
5. Note your deployment name from Model Deployments

### OpenRouter (100+ Models)
1. Go to [openrouter.ai](https://openrouter.ai)
2. Sign up / Sign in
3. Go to Keys → Create Key
4. Copy the key (starts with `sk-or-`)

### Groq (Fast Inference)
1. Go to [console.groq.com](https://console.groq.com)
2. Sign up / Sign in
3. Go to API Keys → Create API Key
4. Copy the key

### Google Gemini
1. Go to [aistudio.google.com](https://aistudio.google.com)
2. Sign in with Google account
3. Get API Key
4. Copy the key

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

## Features

✅ **8 AI Providers** - Anthropic, OpenAI, Azure, OpenRouter, Google, Groq, Mistral, xAI  
✅ **Azure OpenAI Integration** - Use existing or deploy new resource  
✅ **Pre-configured Messaging** - Telegram or Discord ready on boot  
✅ **Full SSH Access** - Connect and manage directly  
✅ **Persistent Storage** - Full disk, survives restarts  
✅ **systemd Service** - Auto-starts on boot  
✅ **Easy Updates** - `npm install -g clawdbot@latest`  

---

## Security Recommendations

1. **Restrict SSH**: Update NSG to allow SSH only from your IP
2. **Use SSH keys**: Never use password authentication
3. **API key security**: Keys stored with 600 permissions
4. **Regular updates**: Keep OpenCLAW and system packages updated

```bash
# Restrict SSH to your IP only
az network nsg rule update \
  --resource-group <rg-name> \
  --nsg-name <vm-name>-nsg \
  --name SSH \
  --source-address-prefix "YOUR_IP/32"
```
