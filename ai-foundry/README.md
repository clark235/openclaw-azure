# Azure AI Foundry Integration

Deploy your own AI endpoint with Azure AI Foundry and connect OpenClaw to it.

## What is Azure AI Foundry?

Azure AI Foundry (formerly Azure AI Studio) lets you deploy AI models to your own Azure subscription. You get:

- **Your own endpoint** — Models run in your Azure account
- **Model choice** — GPT-4o, Llama 3, Phi-3, Mistral, and more
- **Data privacy** — Your data stays in your Azure tenant
- **Cost control** — Pay for what you use, use Azure credits

## Deployment Options

### Option 1: Deploy Everything (Recommended)

One-click deploys both Azure AI Foundry AND OpenClaw, pre-connected:

[![Deploy Full Stack](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fai-foundry%2Fazuredeploy-fullstack.json)

**What gets deployed:**
- Azure AI Hub (AI Foundry workspace)
- Azure AI Project
- Model deployment (GPT-4o or your choice)
- OpenClaw VM pre-configured to use the endpoint
- Telegram/Discord channel (optional)

### Option 2: Deploy AI Foundry Only

Already have OpenClaw? Just add an AI Foundry endpoint:

[![Deploy AI Foundry](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fclark235%2Fopenclaw-azure%2Fmain%2Fai-foundry%2Fazuredeploy-foundry.json)

Then configure OpenClaw to use it (see below).

### Option 3: Use Existing AI Foundry

If you already have an Azure AI Foundry endpoint:

1. Get your endpoint URL from AI Foundry portal
2. Get your API key
3. Deploy OpenClaw with `azure-foundry` provider:

```bash
./scripts/deploy.sh --preset foundry-telegram --name mybot
```

Or use the one-click deploy with these settings:
- AI Provider: `azure-foundry`
- Azure AI Foundry Endpoint: `https://your-project.region.models.ai.azure.com`
- Azure AI Foundry Deployment: `gpt-4o` (or your model name)
- API Key: Your key from AI Foundry

---

## Connecting OpenClaw to AI Foundry

### Environment Variables

```bash
AZURE_FOUNDRY_ENDPOINT="https://your-project.eastus.models.ai.azure.com"
AZURE_FOUNDRY_DEPLOYMENT="gpt-4o"
AZURE_FOUNDRY_API_KEY="YOUR_API_KEY_HERE"
```

### Clawdbot Config

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "azure-foundry/gpt-4o"
      }
    }
  },
  "providers": {
    "azure-foundry": {
      "endpoint": "https://your-project.eastus.models.ai.azure.com",
      "deployment": "gpt-4o",
      "apiKey": "YOUR_API_KEY_HERE"
    }
  }
}
```

---

## Available Models in AI Foundry

| Model | Best For | Notes |
|-------|----------|-------|
| **GPT-4o** | General purpose | Microsoft-hosted OpenAI |
| **GPT-4o-mini** | Cost-effective | Good balance |
| **Llama 3.1 70B** | Open source | Meta's best |
| **Llama 3.1 8B** | Fast + cheap | Lightweight |
| **Phi-3** | Edge/mobile | Microsoft's small model |
| **Mistral Large** | EU alternative | Strong reasoning |
| **Cohere Command R+** | Enterprise | RAG optimized |

---

## Cost Estimate

| Component | Monthly Cost |
|-----------|-------------|
| AI Hub + Project | ~$0 (metadata only) |
| Model inference | Pay-per-token (varies) |
| OpenClaw VM | ~$16 |

**Example:** GPT-4o at moderate use (~100k tokens/day) ≈ $30-50/mo

---

## CLI Deployment

```bash
# Full stack (AI Foundry + OpenClaw)
az deployment group create \
  --resource-group openclaw-rg \
  --template-file ai-foundry/azuredeploy-fullstack.json \
  --parameters \
    vmName="openclaw" \
    aiModel="gpt-4o" \
    messagingChannel="telegram" \
    telegramBotToken="YOUR_TELEGRAM_TOKEN_HERE"

# AI Foundry only
az deployment group create \
  --resource-group ai-foundry-rg \
  --template-file ai-foundry/azuredeploy-foundry.json \
  --parameters \
    projectName="myai" \
    modelName="gpt-4o"
```

---

## Troubleshooting

### "Model not available in region"

Some models are only available in specific regions:
- GPT-4o: East US, West US, Sweden Central
- Llama: East US 2, West US 3

### "Quota exceeded"

Request quota increase in Azure Portal → Subscriptions → Usage + Quotas.

### "Endpoint not responding"

1. Check AI Foundry portal for deployment status
2. Verify endpoint URL format: `https://<project>.<region>.models.ai.azure.com`
3. Test with curl:
```bash
curl -X POST "https://your-endpoint/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-01" \
  -H "api-key: YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}'
```
