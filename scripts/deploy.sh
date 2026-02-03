#!/bin/bash
#
# OpenClaw Azure Deployment Script
# Deploy one or multiple OpenClaw bots to Azure in minutes
#
# Usage:
#   ./deploy.sh --preset telegram-claude --name mybot
#   ./deploy.sh --preset telegram-claude --name bot --count 5  # Creates bot-1 through bot-5
#   ./deploy.sh --config bots.json  # Deploy multiple from config file
#   ./deploy.sh --list-presets
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PRESETS_DIR="$ROOT_DIR/presets"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults
LOCATION="eastus"
VM_SIZE="Standard_B1ms"
DEPLOYMENT_TYPE="vm"

usage() {
    cat << EOF
${BLUE}OpenClaw Azure Deployment${NC}

${YELLOW}Single Bot:${NC}
  $0 --preset <preset-name> --name <bot-name> [options]

${YELLOW}Multiple Bots:${NC}
  $0 --preset <preset-name> --name <base-name> --count <n> [options]
  $0 --config <bots.json>

${YELLOW}Options:${NC}
  --preset <name>       Use a preset (telegram-claude, discord-gpt4, etc.)
  --name <name>         Bot name (used for resource group and DNS)
  --count <n>           Deploy n instances (name-1, name-2, ...)
  --config <file>       Deploy multiple bots from JSON config
  --location <region>   Azure region (default: eastus)
  --size <vm-size>      VM size (default: Standard_B1ms)
  --type <vm|container> Deployment type (default: vm)
  --dry-run            Show what would be deployed
  --list-presets       List available presets
  --help               Show this help

${YELLOW}Environment Variables:${NC}
  Set these before running or pass via --env-file:
  
  ANTHROPIC_API_KEY    Anthropic API key
  OPENAI_API_KEY       OpenAI API key  
  GROQ_API_KEY         Groq API key
  VENICE_API_KEY       Venice AI API key
  TELEGRAM_TOKEN       Telegram bot token
  DISCORD_TOKEN        Discord bot token
  DISCORD_APP_ID       Discord application ID
  SLACK_BOT_TOKEN      Slack bot OAuth token
  SLACK_APP_TOKEN      Slack app-level token

${YELLOW}Examples:${NC}
  # Single Telegram bot with Claude
  export ANTHROPIC_API_KEY="YOUR_ANTHROPIC_KEY_HERE"
  export TELEGRAM_TOKEN="YOUR_TELEGRAM_TOKEN_HERE"
  $0 --preset telegram-claude --name mybot

  # 5 Discord bots with GPT-4
  export OPENAI_API_KEY="YOUR_OPENAI_KEY_HERE"
  export DISCORD_TOKEN="YOUR_DISCORD_TOKEN_HERE"
  $0 --preset discord-gpt4 --name gamebot --count 5

  # Deploy from config file
  $0 --config my-bots.json

EOF
}

list_presets() {
    echo -e "${BLUE}Available Presets:${NC}\n"
    for preset in "$PRESETS_DIR"/*.json; do
        name=$(basename "$preset" .json)
        desc=$(jq -r '.description // "No description"' "$preset")
        difficulty=$(jq -r '.difficulty // "unknown"' "$preset")
        cost=$(jq -r '.monthlyCost // "varies"' "$preset")
        echo -e "${GREEN}$name${NC}"
        echo "  $desc"
        echo "  Difficulty: $difficulty | Cost: $cost"
        echo ""
    done
}

validate_preset() {
    local preset_name="$1"
    local preset_file="$PRESETS_DIR/$preset_name.json"
    
    if [[ ! -f "$preset_file" ]]; then
        echo -e "${RED}Error: Preset '$preset_name' not found${NC}"
        echo "Available presets:"
        ls "$PRESETS_DIR"/*.json 2>/dev/null | xargs -I{} basename {} .json
        exit 1
    fi
    
    echo "$preset_file"
}

check_required_vars() {
    local preset_file="$1"
    local missing=()
    
    while IFS= read -r line; do
        local key=$(echo "$line" | jq -r '.key')
        local env=$(echo "$line" | jq -r '.env')
        local desc=$(echo "$line" | jq -r '.description')
        
        if [[ -z "${!env}" ]]; then
            missing+=("$env: $desc")
        fi
    done < <(jq -c '.required[]' "$preset_file")
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}Missing required environment variables:${NC}"
        for var in "${missing[@]}"; do
            echo "  - $var"
        done
        exit 1
    fi
}

deploy_single() {
    local name="$1"
    local preset_file="$2"
    local dry_run="$3"
    
    local resource_group="openclaw-$name-rg"
    local ai_provider=$(jq -r '.config.aiProvider' "$preset_file")
    local ai_model=$(jq -r '.config.aiModel // ""' "$preset_file")
    local channel=$(jq -r '.config.channel' "$preset_file")
    
    echo -e "${BLUE}Deploying: $name${NC}"
    echo "  Resource Group: $resource_group"
    echo "  Location: $LOCATION"
    echo "  AI Provider: $ai_provider"
    echo "  Channel: $channel"
    
    if [[ "$dry_run" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN] Would create resources${NC}"
        return 0
    fi
    
    # Create resource group
    echo "  Creating resource group..."
    az group create --name "$resource_group" --location "$LOCATION" --output none
    
    # Build parameters
    local params="adminUsername=azureuser"
    params="$params adminPasswordOrKey=\"$(cat ~/.ssh/id_ed25519.pub 2>/dev/null || cat ~/.ssh/id_rsa.pub 2>/dev/null || echo 'REPLACE_WITH_SSH_KEY')\""
    params="$params vmName=$name"
    params="$params aiProvider=$ai_provider"
    
    # Map provider to API key env var
    case "$ai_provider" in
        anthropic) params="$params aiApiKey=$ANTHROPIC_API_KEY" ;;
        openai) params="$params aiApiKey=$OPENAI_API_KEY" ;;
        groq) params="$params aiApiKey=$GROQ_API_KEY" ;;
        venice) params="$params aiApiKey=$VENICE_API_KEY" ;;
        azure-openai) 
            params="$params aiApiKey=$AZURE_OPENAI_KEY"
            params="$params azureOpenAIEndpoint=$AZURE_OPENAI_ENDPOINT"
            params="$params azureOpenAIDeployment=$AZURE_OPENAI_DEPLOYMENT"
            ;;
        azure-foundry)
            params="$params aiApiKey=$AZURE_FOUNDRY_API_KEY"
            params="$params azureFoundryEndpoint=$AZURE_FOUNDRY_ENDPOINT"
            params="$params azureFoundryDeployment=$AZURE_FOUNDRY_DEPLOYMENT"
            ;;
        *) params="$params aiApiKey=$AI_API_KEY" ;;
    esac
    
    # Add channel-specific params
    case "$channel" in
        telegram)
            params="$params messagingChannel=telegram telegramBotToken=$TELEGRAM_TOKEN"
            ;;
        discord)
            params="$params messagingChannel=discord discordBotToken=$DISCORD_TOKEN"
            [[ -n "$DISCORD_APP_ID" ]] && params="$params discordAppId=$DISCORD_APP_ID"
            ;;
        slack)
            params="$params messagingChannel=none"
            # Slack configured post-deployment
            ;;
        *)
            params="$params messagingChannel=none"
            ;;
    esac
    
    # Deploy
    echo "  Deploying Azure resources..."
    local template="$ROOT_DIR/vm/azuredeploy-ultimate.json"
    
    az deployment group create \
        --resource-group "$resource_group" \
        --template-file "$template" \
        --parameters $params \
        --output none
    
    # Get outputs
    local ip=$(az deployment group show \
        --resource-group "$resource_group" \
        --name "$(az deployment group list -g "$resource_group" --query '[0].name' -o tsv)" \
        --query 'properties.outputs.publicIpAddress.value' -o tsv 2>/dev/null || echo "pending")
    
    echo -e "  ${GREEN}✓ Deployed!${NC}"
    echo "  Public IP: $ip"
    echo "  SSH: ssh azureuser@$ip"
    echo ""
}

deploy_from_config() {
    local config_file="$1"
    local dry_run="$2"
    
    if [[ ! -f "$config_file" ]]; then
        echo -e "${RED}Error: Config file not found: $config_file${NC}"
        exit 1
    fi
    
    local count=$(jq '.bots | length' "$config_file")
    echo -e "${BLUE}Deploying $count bots from config${NC}\n"
    
    for ((i=0; i<count; i++)); do
        local bot=$(jq ".bots[$i]" "$config_file")
        local name=$(echo "$bot" | jq -r '.name')
        local preset=$(echo "$bot" | jq -r '.preset')
        
        # Export bot-specific env vars
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                export "$line"
            fi
        done < <(echo "$bot" | jq -r '.env // {} | to_entries[] | "\(.key)=\(.value)"')
        
        local preset_file=$(validate_preset "$preset")
        deploy_single "$name" "$preset_file" "$dry_run"
    done
}

# Parse arguments
PRESET=""
NAME=""
COUNT=1
CONFIG=""
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        --preset) PRESET="$2"; shift 2 ;;
        --name) NAME="$2"; shift 2 ;;
        --count) COUNT="$2"; shift 2 ;;
        --config) CONFIG="$2"; shift 2 ;;
        --location) LOCATION="$2"; shift 2 ;;
        --size) VM_SIZE="$2"; shift 2 ;;
        --type) DEPLOYMENT_TYPE="$2"; shift 2 ;;
        --dry-run) DRY_RUN="true"; shift ;;
        --list-presets) list_presets; exit 0 ;;
        --help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI (az) not found. Install from https://aka.ms/installazurecli${NC}"
    exit 1
fi

# Check jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq not found. Install with: apt install jq${NC}"
    exit 1
fi

# Deploy from config file
if [[ -n "$CONFIG" ]]; then
    deploy_from_config "$CONFIG" "$DRY_RUN"
    exit 0
fi

# Deploy from preset
if [[ -z "$PRESET" ]] || [[ -z "$NAME" ]]; then
    echo -e "${RED}Error: --preset and --name are required${NC}"
    usage
    exit 1
fi

PRESET_FILE=$(validate_preset "$PRESET")
check_required_vars "$PRESET_FILE"

echo -e "${BLUE}OpenClaw Deployment${NC}"
echo "Preset: $PRESET"
echo "Instances: $COUNT"
echo ""

if [[ $COUNT -eq 1 ]]; then
    deploy_single "$NAME" "$PRESET_FILE" "$DRY_RUN"
else
    for ((i=1; i<=COUNT; i++)); do
        deploy_single "$NAME-$i" "$PRESET_FILE" "$DRY_RUN"
    done
fi

echo -e "${GREEN}Deployment complete!${NC}"
