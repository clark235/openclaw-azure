# OpenCLAW Azure Deployment

One-click deployment of [OpenCLAW](https://github.com/clawdbot/clawdbot) - your self-hosted AI assistant.

## 🚀 Ultimate Deployment (Recommended)

**Choose your AI provider + messaging channel - fully configured in one click!**

[![Deploy Ultimate](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fvm%2Fazuredeploy-ultimate.json)

### Supported AI Providers

| Provider | Models | Best For |
|----------|--------|----------|
| **Anthropic** ⭐ | Claude Opus, Sonnet, Haiku | Best reasoning |
| **OpenAI** | GPT-4o, GPT-4, o1 | General purpose |
| **Azure OpenAI** | GPT-4o (your Azure) | Enterprise / Azure credits |
| **OpenRouter** | 100+ models | Flexibility |
| **Google** | Gemini Pro, Flash | Free tier |
| **Groq** | Llama 3.3 70B | Fastest inference |
| **Mistral** | Mistral Large | European alternative |
| **xAI** | Grok-3 | Latest tech |

### Messaging Channels

| Channel | Setup Time | Difficulty |
|---------|-----------|------------|
| **Telegram** ⭐ | 2 min | Easy |
| **Discord** | 5 min | Medium |
| None | - | Configure later |

**Result:** Deploy → 5 min → Your AI is live and chatting! 🎉

---

## Deployment Options

| Template | AI Provider | Messaging | Use Case |
|----------|-------------|-----------|----------|
| [**Ultimate**](./vm/) ⭐ | ✅ Choose from 8 | ✅ Pre-configured | Production ready |
| [Quick Start](./vm/) | ❌ Add later | ✅ Pre-configured | Just messaging |
| [Basic VM](./vm/) | ❌ Add later | ❌ Add later | Full control |
| [Container](./container/) | ❌ Add later | ❌ Add later | Serverless |

---

## 💰 Cost Summary

### Infrastructure

| Option | Monthly Cost | Best For |
|--------|-------------|----------|
| **VM (B1ms)** ⭐ | **~$16** | Production / Daily use |
| VM (B1s) | ~$9 | Light use |
| Container | ~$32 | Serverless preference |

### AI Provider Costs (Separate)

| Provider | Casual Use | Heavy Use |
|----------|-----------|-----------|
| Anthropic | ~$10/mo | ~$50/mo |
| OpenAI | ~$10/mo | ~$50/mo |
| Groq | Free tier | ~$10/mo |
| Gemini | Free tier | ~$10/mo |

📊 [Detailed VM costs](./vm/#-detailed-cost-breakdown) | [Container costs](./container/#-detailed-cost-breakdown)

---

## Getting Started

### 1. Get Your API Key

| Provider | Where to Get Key |
|----------|-----------------|
| Anthropic | [console.anthropic.com](https://console.anthropic.com) |
| OpenAI | [platform.openai.com](https://platform.openai.com) |
| Azure OpenAI | [Azure Portal](https://portal.azure.com) |
| OpenRouter | [openrouter.ai](https://openrouter.ai) |
| Google | [aistudio.google.com](https://aistudio.google.com) |
| Groq | [console.groq.com](https://console.groq.com) |

### 2. Get Your Bot Token (Optional)

**Telegram (Easiest):**
1. Open Telegram → Search @BotFather
2. Send `/newbot` → Follow prompts
3. Copy token

**Discord:**
1. [discord.com/developers](https://discord.com/developers/applications) → New Application
2. Bot → Add Bot → Copy token
3. Enable Message Content Intent
4. OAuth2 → Invite bot to server

### 3. Deploy

Click the button, fill in the form, wait 5 minutes!

[![Deploy Ultimate](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fvm%2Fazuredeploy-ultimate.json)

---

## Azure OpenAI Integration

### Option A: Use Existing Azure OpenAI

If you already have Azure OpenAI deployed:
1. Select "azure-openai" as AI provider
2. Enter your endpoint URL (e.g., `https://myresource.openai.azure.com`)
3. Enter your deployment name (e.g., `gpt-4o`)
4. Enter your API key

### Option B: Deploy New Azure OpenAI

The template can create a new Azure OpenAI resource:
1. Select "azure-openai" as AI provider
2. Check "Deploy Azure OpenAI" checkbox
3. ⚠️ Requires [Azure OpenAI access approval](https://aka.ms/oai/access)

---

## What is OpenCLAW?

OpenCLAW is an open-source AI assistant that runs on your own infrastructure.

- 🤖 **8 AI Providers** - Claude, GPT, Gemini, Llama, and more
- 💬 **Multi-Channel** - Discord, Telegram, WhatsApp, Signal, Slack
- 🔧 **Extensible** - Skills, plugins, automations
- 🔒 **Self-Hosted** - Your data stays on your server
- ☁️ **Azure Native** - Integrates with Azure OpenAI

---

## Repository Structure

```
openclaw-azure/
├── README.md              ← You are here
├── vm/                    ← Virtual Machine (~$16/mo)
│   ├── README.md          ← VM docs & all AI providers
│   ├── azuredeploy-ultimate.json    ← ⭐ AI + messaging
│   ├── azuredeploy-quickstart.json  ← Messaging only
│   ├── azuredeploy.json             ← Basic VM
│   └── main.bicep
└── container/             ← Container Instance (~$32/mo)
    ├── README.md
    ├── azuredeploy.json
    └── main.bicep
```

---

## CLI Deployment

```bash
# Clone repo
git clone https://github.com/clark235/openclaw-azure.git
cd openclaw-azure

# Create resource group
az group create --name openclaw-rg --location eastus

# Deploy Ultimate with Anthropic + Telegram
az deployment group create \
  --resource-group openclaw-rg \
  --template-file vm/azuredeploy-ultimate.json \
  --parameters \
    adminPasswordOrKey="$(cat ~/.ssh/id_ed25519.pub)" \
    aiProvider="anthropic" \
    aiApiKey="sk-ant-..." \
    messagingChannel="telegram" \
    telegramBotToken="123:ABC..."
```

---

## Resources

- [OpenCLAW Documentation](https://docs.clawd.bot)
- [OpenCLAW GitHub](https://github.com/clawdbot/clawdbot)
- [OpenCLAW Discord](https://discord.com/invite/clawd)
- [Azure OpenAI Access](https://aka.ms/oai/access)

## License

MIT

---

Made with 🔧 by Clark
