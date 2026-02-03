# OpenClaw Azure Deployment

One-click deployment of [OpenClaw](https://github.com/clawdbot/clawdbot) - your self-hosted AI assistant.

**🚀 Deploy 10 bots in 10 minutes** — presets, CLI tools, and multi-instance support.

---

## Quick Start

### Option 1: One-Click Azure Deploy

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fvm%2Fazuredeploy-ultimate.json)

### Option 2: Interactive CLI

```bash
git clone https://github.com/clark235/openclaw-azure.git
cd openclaw-azure
./scripts/quick-deploy.sh
```

### Option 3: Script Deployment

```bash
# Single bot
export ANTHROPIC_API_KEY="sk-ant-..."
export TELEGRAM_TOKEN="123:ABC..."
./scripts/deploy.sh --preset telegram-claude --name mybot

# 5 bots at once
./scripts/deploy.sh --preset telegram-claude --name support --count 5

# From config file (10 different bots)
./scripts/deploy.sh --config examples/multi-bot-config.json
```

---

## 🎯 Presets (Ready-to-Deploy Configs)

| Preset | AI Provider | Channel | Difficulty | Use Case |
|--------|-------------|---------|------------|----------|
| `telegram-claude` | Anthropic Claude | Telegram | Easy | Best for beginners |
| `telegram-free` | Groq (FREE) | Telegram | Easy | Zero AI cost |
| `discord-gpt4` | OpenAI GPT-4o | Discord | Medium | Gaming communities |
| `discord-coder` | Claude Opus | Discord | Medium | Dev teams |
| `slack-opus` | Claude Opus | Slack | Medium | Team workspaces |
| `whatsapp-gpt` | OpenAI GPT-4o | WhatsApp | Medium | Family/friends |
| `signal-private` | Venice AI | Signal | Hard | Privacy-focused |
| `teams-enterprise` | Azure OpenAI | MS Teams | Hard | Enterprise |

List all presets:
```bash
./scripts/deploy.sh --list-presets
```

---

## 🤖 Supported AI Providers

| Provider | Models | Best For |
|----------|--------|----------|
| **Anthropic** ⭐ | Claude Opus, Sonnet, Haiku | Best reasoning |
| **OpenAI** | GPT-4o, GPT-4, o1 | General purpose |
| **Azure OpenAI** | GPT-4o (your Azure) | Enterprise |
| **Groq** | Llama 3.3 70B | Free tier + fastest |
| **OpenRouter** | 100+ models | Flexibility |
| **Google** | Gemini Pro, Flash | Free tier |
| **Mistral** | Mistral Large | EU alternative |
| **xAI** | Grok-3 | Latest tech |
| **Venice** | Llama + Claude | Privacy-focused |
| **DeepSeek** | DeepSeek Coder | Coding tasks |

[Full provider catalog →](./CATALOG.md#-ai-providers)

---

## 💬 Supported Channels

### Built-in (17 channels!)

| Channel | Setup Time | Notes |
|---------|-----------|-------|
| **Telegram** ⭐ | 2 min | Easiest to start |
| **Discord** | 5 min | Servers + DMs |
| **WhatsApp** | 5 min | QR code pairing |
| **Slack** | 10 min | Workspace apps |
| **Signal** | 15 min | Privacy-focused |
| **iMessage** | 10 min | macOS only |

### Plugin Channels

MS Teams, Matrix, Mattermost, Nostr, Nextcloud Talk, and more.

[Full channel catalog →](./CATALOG.md#-messaging-channels)

---

## 💰 Cost

| Component | Monthly Cost |
|-----------|-------------|
| Azure VM (B1ms) | ~$16 |
| AI Provider | $0-100+ (usage-based) |

**Free tier option:** Use `telegram-free` preset with Groq = $16/mo total!

---

## 📁 Repository Structure

```
openclaw-azure/
├── README.md              ← You are here
├── CATALOG.md            ← All providers + channels
├── CONTRIBUTING.md       ← How to add new stuff
│
├── vm/                   ← VM templates (~$16/mo)
│   ├── azuredeploy-ultimate.json    ⭐ Full featured
│   ├── azuredeploy-quickstart.json  Messaging only
│   └── azuredeploy.json             Basic VM
│
├── container/            ← Container templates (~$32/mo)
│
├── presets/              ← Ready-to-use configs
│   ├── telegram-claude.json
│   ├── discord-gpt4.json
│   ├── telegram-free.json
│   └── ...
│
├── scripts/              ← CLI deployment tools
│   ├── deploy.sh         ← Main script
│   └── quick-deploy.sh   ← Interactive wizard
│
└── examples/
    └── multi-bot-config.json  ← Deploy 10 bots at once
```

---

## 🔧 CLI Reference

### Deploy a single bot
```bash
./scripts/deploy.sh --preset <preset-name> --name <bot-name>
```

### Deploy multiple identical bots
```bash
./scripts/deploy.sh --preset <preset-name> --name <base-name> --count 5
# Creates: base-name-1, base-name-2, ..., base-name-5
```

### Deploy from config file
```bash
./scripts/deploy.sh --config my-bots.json
```

### Options
```
--preset <name>       Use a preset configuration
--name <name>         Bot name (used for Azure resources)
--count <n>           Deploy n identical instances
--config <file>       Deploy multiple bots from JSON config
--location <region>   Azure region (default: eastus)
--dry-run            Preview without deploying
--list-presets       Show available presets
```

### Environment Variables
```bash
# AI Providers
ANTHROPIC_API_KEY    # Anthropic
OPENAI_API_KEY       # OpenAI
GROQ_API_KEY         # Groq
VENICE_API_KEY       # Venice AI

# Channels
TELEGRAM_TOKEN       # Telegram bot token
DISCORD_TOKEN        # Discord bot token
DISCORD_APP_ID       # Discord app ID
SLACK_BOT_TOKEN      # Slack bot token
SLACK_APP_TOKEN      # Slack app-level token
```

---

## 🔄 Keeping Updated

This repo tracks Clawdbot releases. To get notified of new channels and providers:

1. **Star & Watch** this repo
2. **Watch** [clawdbot/clawdbot](https://github.com/clawdbot/clawdbot) for releases

Want to add a new provider or channel? See [CONTRIBUTING.md](./CONTRIBUTING.md).

---

## 📚 Resources

- [OpenClaw Documentation](https://docs.clawd.bot)
- [OpenClaw GitHub](https://github.com/clawdbot/clawdbot)
- [OpenClaw Discord](https://discord.com/invite/clawd)
- [Provider Catalog](./CATALOG.md)

---

## License

MIT

---

Made with 🔧 by Clark
