# Contributing to OpenClaw Azure

Thanks for your interest in contributing! This guide explains how to add new AI providers, channels, and presets.

## Repository Structure

```
openclaw-azure/
├── README.md              # Main documentation
├── CATALOG.md            # Complete provider/channel reference
├── CONTRIBUTING.md       # This file
├── vm/                   # VM deployment templates
│   ├── azuredeploy-ultimate.json   # Full template with all providers
│   ├── azuredeploy-quickstart.json # Messaging-only template
│   └── azuredeploy.json            # Basic VM template
├── container/            # Container deployment templates
├── presets/              # Ready-to-use configurations
│   ├── telegram-claude.json
│   ├── discord-gpt4.json
│   └── ...
├── scripts/              # Deployment CLI tools
│   ├── deploy.sh         # Main deployment script
│   └── quick-deploy.sh   # Interactive guided deployment
├── examples/             # Example configurations
│   └── multi-bot-config.json
└── schemas/              # JSON schemas for validation
```

## Adding a New AI Provider

### 1. Update CATALOG.md

Add the provider to the AI Providers table:

```markdown
| `newprovider` | Provider Name | model-1, model-2 | API Key | Notes |
```

### 2. Update VM Template

Edit `vm/azuredeploy-ultimate.json`:

1. Add to `aiProvider` allowed values:
```json
"allowedValues": ["anthropic", "openai", ..., "newprovider"]
```

2. Add environment variable mapping in the deployment script section:
```json
{
  "name": "NEWPROVIDER_API_KEY",
  "secureValue": "[if(equals(parameters('aiProvider'), 'newprovider'), parameters('aiApiKey'), '')]"
}
```

3. Add to the Clawdbot config generation:
```bash
if [ "$AI_PROVIDER" = "newprovider" ]; then
  # Provider-specific config
fi
```

### 3. Update deploy.sh

Add the provider to the API key mapping:
```bash
case "$ai_provider" in
    ...
    newprovider) params="$params aiApiKey=$NEWPROVIDER_API_KEY" ;;
esac
```

### 4. Create a Preset (Optional)

Create `presets/telegram-newprovider.json`:
```json
{
  "name": "telegram-newprovider",
  "description": "Telegram bot with NewProvider",
  "config": {
    "aiProvider": "newprovider",
    "aiModel": "newprovider/model-name",
    "channel": "telegram"
  },
  "required": [
    { "key": "aiApiKey", "env": "NEWPROVIDER_API_KEY", "description": "..." },
    { "key": "telegramToken", "env": "TELEGRAM_TOKEN", "description": "..." }
  ]
}
```

## Adding a New Channel

### 1. Check Clawdbot Support

First verify the channel is supported by Clawdbot:
- Built-in: Check [Clawdbot docs](https://docs.clawd.bot/channels/)
- Plugin: Note the plugin package name

### 2. Update CATALOG.md

Add to the Messaging Channels table.

### 3. Update VM Template

For built-in channels, add to `messagingChannel` allowed values and add the token parameter.

For plugin channels, the user must install the plugin post-deployment.

### 4. Create Channel-Specific Presets

Create presets for popular provider+channel combinations.

## Adding a New Preset

Presets make deployment easy. Create a JSON file in `presets/`:

```json
{
  "$schema": "../schemas/preset.schema.json",
  "name": "unique-preset-name",
  "description": "Human-readable description",
  "difficulty": "easy|medium|hard",
  "monthlyCost": "$X infra + ~$Y AI",
  "config": {
    "aiProvider": "provider-id",
    "aiModel": "provider/model",
    "channel": "channel-id"
  },
  "required": [
    {
      "key": "paramName",
      "env": "ENV_VAR_NAME",
      "description": "What this is and where to get it"
    }
  ],
  "setup": [
    "Step 1...",
    "Step 2..."
  ],
  "plugins": ["@clawdbot/channel-xxx"],  // Optional
  "notes": "Additional info"  // Optional
}
```

## Watching for Upstream Changes

The main Clawdbot repository frequently adds new channels and providers:

### GitHub Notifications

1. Star and Watch: https://github.com/clawdbot/clawdbot
2. Set watch to "Custom" → Releases and Discussions

### Key Files to Monitor

- `docs/channels/` — New channel documentation
- `docs/providers/` — New provider documentation  
- `CHANGELOG.md` — Version changes
- `package.json` — New plugin packages

### Update Workflow

When Clawdbot adds something new:

1. Check if it's a built-in or plugin
2. Update CATALOG.md
3. Update templates if built-in
4. Create relevant presets
5. Test deployment
6. Submit PR

## Testing

Before submitting:

```bash
# Validate JSON syntax
for f in presets/*.json; do jq . "$f" > /dev/null && echo "✓ $f"; done

# Dry-run deployment
./scripts/deploy.sh --preset your-preset --name test --dry-run

# Full test (costs ~$0.50)
./scripts/deploy.sh --preset telegram-free --name test-$(date +%s)
# Then delete: az group delete -n openclaw-test-xxx-rg
```

## Pull Request Guidelines

1. **One feature per PR** — Keep changes focused
2. **Update docs** — CATALOG.md, README if needed
3. **Include preset** — If adding provider/channel, add a preset
4. **Test** — At minimum, dry-run; ideally, real deploy

## Questions?

- [Clawdbot Discord](https://discord.com/invite/clawd)
- [GitHub Issues](https://github.com/clark235/openclaw-azure/issues)
