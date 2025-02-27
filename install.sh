#!/bin/bash

INSTALL_PATH="/usr/local/bin/system-status"
CONFIG_FILE="/etc/system_status.conf"

echo "Installing system-status..."

# Ask for webhook URL
read -p "Enter your Discord Webhook URL: " WEBHOOK_URL

# Save webhook to a config file
echo "$WEBHOOK_URL" | sudo tee "$CONFIG_FILE" > /dev/null

# Move script to /usr/local/bin
sudo cp system_status.sh "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

# Create a command for setting a new webhook
echo '#!/bin/bash' | sudo tee /usr/local/bin/system-status-set-webhook > /dev/null
echo "echo \$1 | sudo tee $CONFIG_FILE" | sudo tee -a /usr/local/bin/system-status-set-webhook > /dev/null
sudo chmod +x /usr/local/bin/system-status-set-webhook

echo "Installation complete!"
echo "Run 'system-status' to check your system and send it to Discord."
echo "To update the webhook, use: system-status-set-webhook <new-webhook-url>"
