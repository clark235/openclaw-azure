#!/bin/bash
#
# OpenClaw Quick Deploy - Interactive guided deployment
#
# Usage: ./quick-deploy.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << 'EOF'
   ___                   ____ _                
  / _ \ _ __   ___ _ __ / ___| | __ ___      __
 | | | | '_ \ / _ \ '_ \ |   | |/ _` \ \ /\ / /
 | |_| | |_) |  __/ | | | |___| | (_| |\ V  V / 
  \___/| .__/ \___|_| |_|\____|_|\__,_| \_/\_/  
       |_|                                      
        Azure Quick Deploy
EOF
echo -e "${NC}"

# Check dependencies
for cmd in az jq; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Error: $cmd is required but not installed.${NC}"
        exit 1
    fi
done

# Check Azure login
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Not logged into Azure. Running 'az login'...${NC}"
    az login
fi

echo -e "${GREEN}Azure CLI ready!${NC}\n"

# Select preset
echo -e "${BLUE}Step 1: Choose a preset${NC}\n"

presets=(
    "telegram-claude:Telegram + Claude (Best for beginners)"
    "discord-gpt4:Discord + GPT-4o (Gaming communities)"
    "telegram-free:Telegram + Groq (FREE AI tier!)"
    "slack-opus:Slack + Claude Opus (Team workspaces)"
    "discord-coder:Discord + Claude Opus (Dev teams)"
    "whatsapp-gpt:WhatsApp + GPT-4o (Family/friends)"
)

PS3=$'\n'"Select preset (1-${#presets[@]}): "
select opt in "${presets[@]}"; do
    if [[ -n "$opt" ]]; then
        PRESET="${opt%%:*}"
        echo -e "\n${GREEN}Selected: $PRESET${NC}\n"
        break
    fi
done

# Get bot name
echo -e "${BLUE}Step 2: Name your bot${NC}"
read -p "Bot name (lowercase, no spaces): " BOT_NAME
BOT_NAME=$(echo "$BOT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Load preset requirements
PRESET_FILE="$ROOT_DIR/presets/$PRESET.json"
echo -e "\n${BLUE}Step 3: Enter credentials${NC}\n"

# Read required vars from preset
while IFS= read -r line; do
    key=$(echo "$line" | jq -r '.key')
    env_var=$(echo "$line" | jq -r '.env')
    desc=$(echo "$line" | jq -r '.description')
    
    echo "$desc"
    read -p "$env_var: " value
    export "$env_var=$value"
    echo ""
done < <(jq -c '.required[]' "$PRESET_FILE")

# Confirm
echo -e "${BLUE}Step 4: Confirm deployment${NC}\n"
echo "Bot Name: $BOT_NAME"
echo "Preset: $PRESET"
echo "Location: eastus"
echo "Estimated Cost: $(jq -r '.monthlyCost' "$PRESET_FILE")"
echo ""

read -p "Deploy now? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Cancelled."
    exit 0
fi

# Deploy
echo -e "\n${YELLOW}Deploying...${NC}\n"
"$SCRIPT_DIR/deploy.sh" --preset "$PRESET" --name "$BOT_NAME"

echo -e "\n${GREEN}🎉 Deployment complete!${NC}"
echo ""
echo "Next steps:"

channel=$(jq -r '.config.channel' "$PRESET_FILE")
case "$channel" in
    telegram)
        echo "  1. Open Telegram and search for your bot"
        echo "  2. Send /start to begin chatting!"
        ;;
    discord)
        echo "  1. Your bot should appear online in Discord"
        echo "  2. Mention the bot or DM it to chat"
        ;;
    whatsapp)
        echo "  1. SSH to your VM: ssh azureuser@<IP>"
        echo "  2. Run: clawdbot channels login"
        echo "  3. Scan the QR code with WhatsApp"
        ;;
    *)
        echo "  1. SSH to your VM to complete channel setup"
        ;;
esac

echo ""
echo "Dashboard: http://<VM-IP>:18789"
