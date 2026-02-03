# OpenClaw Catalog

Complete list of supported AI providers and messaging channels.
Use these identifiers in deployment configs and presets.

---

## 🤖 AI Providers

| ID | Provider | Models | Auth Type | Notes |
|----|----------|--------|-----------|-------|
| `anthropic` | Anthropic | claude-opus-4-5, claude-sonnet-4, claude-haiku-3-5 | API Key | Best reasoning |
| `openai` | OpenAI | gpt-4o, gpt-4-turbo, o1, o1-mini | API Key | General purpose |
| `azure-openai` | Azure OpenAI | gpt-4o (your deployment) | API Key + Endpoint | Enterprise |
| `openrouter` | OpenRouter | 100+ models | API Key | Multi-provider |
| `google` | Google AI | gemini-2.0-flash, gemini-pro | API Key | Free tier |
| `groq` | Groq | llama-3.3-70b, mixtral | API Key | Fastest inference |
| `mistral` | Mistral AI | mistral-large, codestral | API Key | EU alternative |
| `xai` | xAI | grok-3, grok-2 | API Key | Latest tech |
| `venice` | Venice AI | llama-3.3-70b, claude-opus-45 | API Key | Privacy-focused |
| `bedrock` | AWS Bedrock | claude, llama, titan | AWS Credentials | AWS native |
| `ollama` | Ollama | Local models | None (local) | Self-hosted |
| `moonshot` | Moonshot/Kimi | moonshot-v1-128k | API Key | Long context |
| `qwen` | Qwen | qwen-max, qwen-plus | API Key | Alibaba |
| `minimax` | MiniMax | abab6.5 | API Key | Chinese market |
| `deepseek` | DeepSeek | deepseek-chat, deepseek-coder | API Key | Coding |
| `together` | Together AI | Various open models | API Key | Open source |
| `perplexity` | Perplexity | pplx-70b-online | API Key | Web search |

### Provider Links

| Provider | Console URL |
|----------|------------|
| Anthropic | https://console.anthropic.com |
| OpenAI | https://platform.openai.com |
| Azure OpenAI | https://portal.azure.com |
| OpenRouter | https://openrouter.ai/keys |
| Google AI | https://aistudio.google.com |
| Groq | https://console.groq.com |
| Mistral | https://console.mistral.ai |
| xAI | https://console.x.ai |
| Venice | https://venice.ai/settings |
| Together | https://api.together.xyz |
| DeepSeek | https://platform.deepseek.com |

---

## 💬 Messaging Channels

### Built-in (no plugin required)

| ID | Channel | Setup | Difficulty | Notes |
|----|---------|-------|------------|-------|
| `telegram` | Telegram | Bot token from @BotFather | Easy | Best for getting started |
| `discord` | Discord | Bot token + OAuth | Medium | Servers + DMs |
| `whatsapp` | WhatsApp | QR code scan | Medium | Most popular globally |
| `slack` | Slack | Bolt app token | Medium | Workspace apps |
| `googlechat` | Google Chat | Service account | Hard | Enterprise |
| `signal` | Signal | signal-cli setup | Hard | Privacy-focused |
| `imessage` | iMessage | macOS only (imsg) | Hard | Apple ecosystem |
| `bluebubbles` | BlueBubbles | macOS server | Medium | Better iMessage |

### Plugins (install separately)

| ID | Channel | Plugin | Notes |
|----|---------|--------|-------|
| `msteams` | MS Teams | `@clawdbot/channel-msteams` | Enterprise |
| `matrix` | Matrix | `@clawdbot/channel-matrix` | Decentralized |
| `mattermost` | Mattermost | `@clawdbot/channel-mattermost` | Self-hosted Slack |
| `nostr` | Nostr | `@clawdbot/channel-nostr` | Decentralized |
| `nextcloud` | Nextcloud Talk | `@clawdbot/channel-nextcloud` | Self-hosted |
| `tlon` | Tlon/Urbit | `@clawdbot/channel-tlon` | Urbit messenger |
| `zalo` | Zalo (Bot) | `@clawdbot/channel-zalo` | Vietnam |
| `zalouser` | Zalo (Personal) | `@clawdbot/channel-zalouser` | Vietnam personal |

### Channel Setup Quick Reference

**Telegram (2 min):**
```
1. Open Telegram → @BotFather
2. /newbot → name it → copy token
```

**Discord (5 min):**
```
1. discord.com/developers → New Application
2. Bot → Add Bot → Copy token
3. OAuth2 → bot scope → Send Messages permission
4. Generate URL → Add to server
```

**WhatsApp (5 min):**
```
1. Run: clawdbot channels login
2. Scan QR with WhatsApp
```

**Slack (10 min):**
```
1. api.slack.com/apps → Create App
2. OAuth & Permissions → Add scopes
3. Install to workspace → Copy Bot Token
```

---

## 🎯 Recommended Combinations

| Use Case | Provider | Channel | Preset Name |
|----------|----------|---------|-------------|
| Quick start | `anthropic` | `telegram` | `telegram-claude` |
| Gaming community | `openai` | `discord` | `discord-gpt4` |
| Team workspace | `anthropic` | `slack` | `slack-opus` |
| Privacy-first | `venice` | `signal` | `signal-private` |
| Enterprise | `azure-openai` | `msteams` | `teams-enterprise` |
| Free tier | `groq` | `telegram` | `telegram-free` |
| Coding assistant | `anthropic` | `discord` | `discord-coder` |
| Family/friends | `openai` | `whatsapp` | `whatsapp-gpt` |

---

## 📝 Config Examples

### Minimal (Telegram + Claude)
```json
{
  "aiProvider": "anthropic",
  "aiApiKey": "sk-ant-...",
  "channel": "telegram",
  "telegramToken": "123:ABC..."
}
```

### Multi-Channel
```json
{
  "aiProvider": "anthropic",
  "aiApiKey": "sk-ant-...",
  "channels": ["telegram", "discord"],
  "telegramToken": "123:ABC...",
  "discordToken": "MTk..."
}
```

### Enterprise
```json
{
  "aiProvider": "azure-openai",
  "azureEndpoint": "https://myorg.openai.azure.com",
  "azureDeployment": "gpt-4o",
  "aiApiKey": "...",
  "channel": "msteams",
  "teamsAppId": "...",
  "teamsAppSecret": "..."
}
```
