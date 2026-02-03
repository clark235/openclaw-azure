# OpenCLAW Azure Deployment

One-click deployment of [OpenCLAW](https://github.com/clawdbot/clawdbot) - your self-hosted AI assistant.

## Choose Your Deployment

| | [**Virtual Machine**](./vm/) | [**Container**](./container/) |
|--|:--:|:--:|
| **Monthly Cost** | **~$16** ✅ | ~$32 |
| SSH Access | ✅ Yes | ❌ No |
| Customizable | ✅ Full control | ❌ Limited |
| Management | You manage VM | Serverless |
| Best For | **Production / Daily Use** | Testing / Serverless fans |

---

## 🚀 Quick Start (Recommended)

Deploy a VM with your messaging channel pre-configured. Bot connects automatically!

[![Deploy Quick Start](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fvm%2Fazuredeploy-quickstart.json)

**What you need:**
1. SSH public key
2. Telegram or Discord bot token ([how to get one](#getting-a-bot-token))
3. Anthropic API key (optional - can add later)

**Result:** Deploy → Wait 5 min → Message your bot → Start chatting! 🎉

---

## Deployment Options

### Option 1: VM with Quick Start ⭐ Recommended

Pre-configured messaging channel, bot auto-connects.

[![Deploy VM Quick Start](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fvm%2Fazuredeploy-quickstart.json)

📁 [See VM folder for details](./vm/)

### Option 2: VM Basic

Deploy VM, configure channels later via Control UI.

[![Deploy VM](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fvm%2Fazuredeploy.json)

📁 [See VM folder for details](./vm/)

### Option 3: Container (Serverless)

No VM to manage, but costs more.

[![Deploy Container](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fcontainer%2Fazuredeploy.json)

📁 [See Container folder for details](./container/)

---

## 💰 Cost Comparison

### Virtual Machine (Recommended)

| Size | vCPU | RAM | Monthly |
|------|------|-----|---------|
| B1ls | 1 | 0.5 GB | ~$5 |
| B1s | 1 | 1 GB | ~$9 |
| **B1ms** ⭐ | **1** | **2 GB** | **~$16** |
| B2s | 2 | 4 GB | ~$31 |

### Container Instance

| Config | vCPU | RAM | Monthly |
|--------|------|-----|---------|
| Minimal | 1 | 1 GB | ~$27 |
| **Default** | **1** | **2 GB** | **~$32** |
| Medium | 2 | 4 GB | ~$63 |

**Bottom line:** VM is ~50% cheaper for equivalent specs.

📊 [Detailed VM costs](./vm/#-detailed-cost-breakdown) | [Detailed Container costs](./container/#-detailed-cost-breakdown)

---

## Getting a Bot Token

### Telegram (Easiest - 2 minutes)

1. Open Telegram, search for **@BotFather**
2. Send `/newbot`
3. Follow prompts (name + username ending in `bot`)
4. Copy the token: `123456789:ABCdefGHI...`

### Discord (5 minutes)

1. Go to [discord.com/developers/applications](https://discord.com/developers/applications)
2. New Application → name it → Create
3. Go to **Bot** → Add Bot → Yes
4. Click **Reset Token** → Copy it
5. Enable **Message Content Intent** under Privileged Gateway Intents
6. Go to **OAuth2** → URL Generator → Select `bot` → Select permissions
7. Copy invite URL → Open it → Add bot to your server

---

## What is OpenCLAW?

OpenCLAW is an open-source AI assistant that runs on your own infrastructure.

- 🤖 **AI-Powered** - Claude, GPT, or other models
- 💬 **Multi-Channel** - Discord, Telegram, WhatsApp, Signal, Slack
- 🔧 **Extensible** - Skills and plugins
- 🔒 **Self-Hosted** - Your data stays on your server

---

## Repository Structure

```
openclaw-azure/
├── README.md           ← You are here
├── vm/                 ← Virtual Machine deployment
│   ├── README.md       ← VM-specific docs & costs
│   ├── azuredeploy-quickstart.json  ← Quick Start with channel
│   ├── azuredeploy.json             ← Basic VM
│   └── main.bicep                   ← Bicep template
└── container/          ← Container Instance deployment
    ├── README.md       ← Container-specific docs & costs
    ├── azuredeploy.json             ← Container template
    └── main.bicep                   ← Bicep template
```

---

## Resources

- [OpenCLAW Documentation](https://docs.clawd.bot)
- [OpenCLAW GitHub](https://github.com/clawdbot/clawdbot)
- [OpenCLAW Discord](https://discord.com/invite/clawd)

## License

MIT

---

Made with 🔧 by Clark
