# GitHub Webhook Bridge

Azure Function that receives GitHub webhooks and forwards them to your Clawdbot agent.

## Supported Events

| Event | What Happens |
|-------|--------------|
| `issues.opened` | Agent notified of new issue |
| `issues.closed` | Agent notified issue was closed |
| `issue_comment.created` | Agent sees new comment |
| `pull_request.opened` | Agent notified of new PR |
| `pull_request.closed` | Agent notified PR merged/closed |
| `pull_request_review.submitted` | Agent sees PR review |
| `push` | Agent notified of commits |
| `release.published` | Agent notified of new release |

## Deployment

### One-Click Deploy

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fwebhooks%2Fgithub-bridge%2Fazuredeploy.json)

### CLI Deploy

```bash
# Create Function App
az functionapp create \
  --resource-group openclaw-rg \
  --consumption-plan-location eastus \
  --runtime node \
  --runtime-version 20 \
  --functions-version 4 \
  --name github-webhook-bridge \
  --storage-account <storage-account>

# Set configuration
az functionapp config appsettings set \
  --resource-group openclaw-rg \
  --name github-webhook-bridge \
  --settings \
    GITHUB_WEBHOOK_SECRET="YOUR_GITHUB_WEBHOOK_SECRET_HERE" \
    CLAWDBOT_WEBHOOK_URL="https://your-clawdbot:18789/hooks/agent" \
    CLAWDBOT_WEBHOOK_TOKEN="YOUR_CLAWDBOT_HOOK_TOKEN_HERE"

# Deploy code
cd webhooks/github-bridge
func azure functionapp publish github-webhook-bridge
```

## Configuration

### Environment Variables

| Variable | Description |
|----------|-------------|
| `GITHUB_WEBHOOK_SECRET` | Secret for validating GitHub signatures |
| `CLAWDBOT_WEBHOOK_URL` | Your Clawdbot webhook endpoint |
| `CLAWDBOT_WEBHOOK_TOKEN` | Clawdbot hooks.token for auth |
| `REPOS_FILTER` | (Optional) Comma-separated repos to accept |
| `DELIVER_TO_CHANNEL` | (Optional) Send response to channel (discord, telegram, etc.) |
| `DELIVER_TO` | (Optional) Channel ID or phone number |

### GitHub Webhook Setup

1. Go to your repo → Settings → Webhooks → Add webhook
2. **Payload URL**: `https://<function-app>.azurewebsites.net/api/github`
3. **Content type**: `application/json`
4. **Secret**: Same as `GITHUB_WEBHOOK_SECRET`
5. **Events**: Select individual events:
   - Issues
   - Issue comments
   - Pull requests
   - Pull request reviews
   - Pushes
   - Releases

### Clawdbot Configuration

Enable hooks in your Clawdbot config:

```json
{
  "hooks": {
    "enabled": true,
    "token": "YOUR_CLAWDBOT_HOOK_TOKEN_HERE",
    "path": "/hooks"
  }
}
```

## How It Works

1. GitHub sends webhook to Azure Function
2. Function validates `X-Hub-Signature-256` header
3. Function transforms GitHub payload to Clawdbot format:
   ```json
   {
     "message": "[GitHub] New issue #123 in owner/repo: Bug title\n\nBug description...",
     "name": "GitHub",
     "sessionKey": "github:owner/repo:issue:123",
     "deliver": true
   }
   ```
4. Function POSTs to Clawdbot `/hooks/agent`
5. Your agent receives the message and can respond

## Example Agent Response

When you receive a GitHub event, you can:

- **Triage issues**: Label, assign, or respond
- **Review PRs**: Comment on code changes
- **Track releases**: Update documentation
- **Monitor commits**: Alert on sensitive file changes

Example using the `gh` CLI from your agent:

```bash
# Respond to an issue
gh issue comment 123 --repo owner/repo --body "Thanks for reporting! Looking into this."

# Add labels
gh issue edit 123 --repo owner/repo --add-label "bug,triage"
```

## Local Testing

```bash
# Start function locally
cd webhooks/github-bridge
func start

# Test with sample payload
curl -X POST http://localhost:7071/api/github \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: issues" \
  -d '{"action":"opened","issue":{"number":1,"title":"Test"},"repository":{"full_name":"test/repo"}}'
```

## Filtering

To only accept webhooks from specific repos:

```bash
REPOS_FILTER="owner/repo1,owner/repo2"
```

Events from other repos will return 200 but not be forwarded.

## Security

- GitHub signature validation prevents spoofed webhooks
- Clawdbot token prevents unauthorized access to your agent
- Function App can be locked to GitHub IPs (optional)

GitHub webhook IPs: https://api.github.com/meta (look for `hooks` array)
