# Webhook Bridges

Connect external services to your OpenClaw instance via Azure Functions.

## Available Bridges

| Bridge | Source | Events |
|--------|--------|--------|
| [GitHub](./github-bridge/) | GitHub webhooks | Issues, PRs, comments, pushes |

## Architecture

```
┌─────────┐     ┌──────────────────┐     ┌──────────┐     ┌───────┐
│ GitHub  │────▶│  Azure Function  │────▶│ Clawdbot │────▶│ Agent │
│ Webhook │     │  (validates &    │     │ /hooks/* │     │       │
└─────────┘     │   transforms)    │     └──────────┘     └───────┘
                └──────────────────┘
```

1. **GitHub** fires webhook on events (new issue, PR, comment, etc.)
2. **Azure Function** validates GitHub signature, transforms payload
3. **Clawdbot** receives via `/hooks/agent` endpoint
4. **Agent** processes the event and can respond

## Why Azure Function?

- **Security**: Validates GitHub webhook signatures
- **Transform**: Converts GitHub payload to Clawdbot format
- **Public endpoint**: GitHub needs a public URL; your Clawdbot can stay private
- **Cheap**: Pay only for invocations (~$0.20/million requests)

## Quick Start

1. Deploy the GitHub bridge:
   ```bash
   cd webhooks/github-bridge
   func azure functionapp publish <your-function-app>
   ```

2. Configure Clawdbot hooks:
   ```json
   {
     "hooks": {
       "enabled": true,
       "token": "YOUR_WEBHOOK_SECRET_HERE"
     }
   }
   ```

3. Add webhook in GitHub repo settings:
   - URL: `https://<your-function>.azurewebsites.net/api/github`
   - Secret: Your GitHub webhook secret
   - Events: Issues, Pull requests, Issue comments

4. Done! Your agent now receives GitHub events.

## Exposing Clawdbot

The Azure Function needs to reach your Clawdbot instance. Options:

| Method | Complexity | Best For |
|--------|------------|----------|
| **Tailscale Funnel** | Easy | Personal use |
| **Azure VM** | Easy | If Clawdbot runs in Azure |
| **Cloudflare Tunnel** | Medium | Self-hosted |
| **VPN/Private Link** | Hard | Enterprise |

### Tailscale Funnel (Recommended)

```bash
# On your Clawdbot machine
tailscale funnel 18789
```

Your Clawdbot is now at `https://<machine-name>.<tailnet>.ts.net/`

### Azure VM

If Clawdbot runs on an Azure VM in the same subscription, the Function can reach it directly via private IP or public IP.
