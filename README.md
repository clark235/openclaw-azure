# OpenCLAW Azure Deployment

One-click deployment of [OpenCLAW](https://github.com/clawdbot/clawdbot) to Azure.

## 🚀 Quick Start (Recommended)

Deploy with a pre-configured messaging channel - your bot will be ready to chat immediately!

[![Deploy Quick Start](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fazuredeploy-quickstart.json)

**What you'll need:**
1. **SSH Key** - Your public SSH key for VM access
2. **Messaging Token** - Telegram or Discord bot token (see below)
3. **API Key** - Anthropic or OpenAI key (optional - can add later)

### Getting Your Bot Token

#### Telegram (Easiest - 2 minutes)
1. Open Telegram and search for **@BotFather**
2. Send `/newbot` and follow the prompts
3. Copy the token (looks like `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)
4. Paste it in the deployment form

#### Discord (5 minutes)
1. Go to [discord.com/developers/applications](https://discord.com/developers/applications)
2. Click "New Application" → name it → Create
3. Go to "Bot" → "Add Bot" → "Yes, do it!"
4. Click "Reset Token" → Copy the token
5. Enable "Message Content Intent" under Privileged Gateway Intents
6. Go to OAuth2 → URL Generator → Select "bot" → Select permissions (Send Messages, Read Message History)
7. Copy the URL and open it to invite the bot to your server
8. Paste the bot token in the deployment form

---

## Deployment Options

### Option 1: Quick Start (Pre-configured Channel)

Best for getting started fast - bot connects automatically.

[![Deploy Quick Start](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fazuredeploy-quickstart.json)

### Option 2: VM Only (Configure Later)

Deploy the VM first, configure channels via Control UI.

[![Deploy VM](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fazuredeploy.json)

### Option 3: Container (Serverless)

No VM to manage, but costs more (~$35-45/mo vs ~$15/mo).

[![Deploy Container](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fazuredeploy-container.json)

---

## What is OpenCLAW?

OpenCLAW is an open-source AI assistant that runs on your own infrastructure.

- 🤖 AI-powered assistant using Claude, GPT, or other models
- 💬 Multi-channel: Discord, Telegram, WhatsApp, Signal, Slack
- 🔧 Extensible with skills and plugins
- 🔒 Self-hosted: your data stays on your server

---

## Quick Start Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `vmName` | No | VM name (default: openclaw) |
| `vmSize` | No | VM size (default: Standard_B1ms ~$15/mo) |
| `adminPasswordOrKey` | **Yes** | Your SSH public key |
| `messagingChannel` | No | `telegram`, `discord`, or `none` |
| `telegramBotToken` | If Telegram | Token from @BotFather |
| `discordBotToken` | If Discord | Token from Discord Developer Portal |
| `anthropicApiKey` | Recommended | From console.anthropic.com |
| `openaiApiKey` | Optional | From platform.openai.com |

---

## After Deployment

### If you configured Telegram:
1. Wait 3-5 minutes for setup to complete
2. Open Telegram and message your bot
3. Start chatting! 🎉

### If you configured Discord:
1. Wait 3-5 minutes for setup to complete
2. Make sure you've invited the bot to your server
3. DM the bot or @mention it in a channel
4. Start chatting! 🎉

### If no channel configured:
1. Open the `controlUIUrl` from deployment outputs
2. Enter the `gatewayToken` to authenticate
3. Add your API keys and channels in the Control UI

---

## Cost Comparison

| Option | vCPU | RAM | Monthly Cost* |
|--------|------|-----|--------------|
| **VM (B1ms)** | 1 | 2 GB | **~$15** ✓ Recommended |
| VM (B2s) | 2 | 4 GB | ~$30 |
| Container | 1 | 2 GB | ~$35-45 |

*Costs vary by region. VM includes ~$1-2/mo storage.

---

## CLI Deployment

### Quick Start with Telegram
```bash
az deployment group create \
  --resource-group openclaw-rg \
  --template-file azuredeploy-quickstart.json \
  --parameters \
    adminPasswordOrKey="$(cat ~/.ssh/id_ed25519.pub)" \
    messagingChannel="telegram" \
    telegramBotToken="YOUR_BOT_TOKEN" \
    anthropicApiKey="YOUR_API_KEY"
```

### Quick Start with Discord
```bash
az deployment group create \
  --resource-group openclaw-rg \
  --template-file azuredeploy-quickstart.json \
  --parameters \
    adminPasswordOrKey="$(cat ~/.ssh/id_ed25519.pub)" \
    messagingChannel="discord" \
    discordBotToken="YOUR_BOT_TOKEN" \
    anthropicApiKey="YOUR_API_KEY"
```

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

## Troubleshooting

### Bot not responding?

1. **Wait 3-5 minutes** - Setup takes time
2. **Check service status**: `ssh clawdadmin@<fqdn>` then `sudo systemctl status openclaw`
3. **Check logs**: `sudo journalctl -u openclaw -n 50`
4. **Verify token**: Make sure you copied the full bot token

### Telegram specific
- Make sure you messaged @BotFather (not a fake)
- Token format: `123456789:ABCdefGHI...` (numbers:letters)
- Try `/start` command to your bot

### Discord specific
- Enable "Message Content Intent" in Discord Developer Portal
- Make sure bot is invited to your server with correct permissions
- Try @mentioning the bot in a channel

---

## Files

| File | Description |
|------|-------------|
| `azuredeploy-quickstart.json` | **Quick Start** - VM with channel config |
| `azuredeploy.json` | VM only (configure later) |
| `azuredeploy-container.json` | Container deployment |
| `main.bicep` | VM Bicep template |
| `container.bicep` | Container Bicep template |

---

## Security Notes

1. **API keys are stored securely** in `/home/clawdadmin/.clawdbot/env` with restricted permissions
2. **Bot tokens are in the config** file with 600 permissions
3. **Restrict SSH access** after deployment - update NSG to allow only your IP
4. **Use SSH keys** instead of passwords

---

## Resources

- [OpenCLAW Documentation](https://docs.clawd.bot)
- [OpenCLAW GitHub](https://github.com/clawdbot/clawdbot)
- [OpenCLAW Discord](https://discord.com/invite/clawd)
- [Telegram BotFather](https://t.me/botfather)
- [Discord Developer Portal](https://discord.com/developers/applications)

## License

MIT

---

Made with 🔧 by Clark
