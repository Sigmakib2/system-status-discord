#!/bin/bash

INSTALL_PATH="/usr/local/bin/system-status"
CONFIG_FILE="/etc/system_status.conf"
CRON_FILE="/etc/cron.d/system-status-cron"

echo "🔧 Installing system-status..."

# Ask for Discord Webhook URL
read -p "📡 Enter your Discord Webhook URL: " WEBHOOK_URL

# Save webhook to a config file
echo "$WEBHOOK_URL" | sudo tee "$CONFIG_FILE" > /dev/null

# Ask for update interval (in minutes)
read -p "⏳ How often should system status be sent? (in minutes): " INTERVAL

# Validate input
if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
    echo "❌ Invalid input! Please enter a number."
    exit 1
fi

# Move script to /usr/local/bin
sudo cp system_status.sh "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

# Create a cron job
echo "*/$INTERVAL * * * * root /usr/local/bin/system-status" | sudo tee "$CRON_FILE" > /dev/null
sudo chmod 644 "$CRON_FILE"
sudo systemctl restart cron  # Restart cron service

# Create a command for updating the webhook URL
echo '#!/bin/bash' | sudo tee /usr/local/bin/system-status-set-webhook > /dev/null
echo "echo \$1 | sudo tee $CONFIG_FILE" | sudo tee -a /usr/local/bin/system-status-set-webhook > /dev/null
sudo chmod +x /usr/local/bin/system-status-set-webhook

echo "✅ Installation complete!"
echo "🚀 System status will be sent every $INTERVAL minutes."
echo "📢 Run 'system-status' to manually send status to Discord."
echo "🔄 To change the webhook, use: system-status-set-webhook <new-webhook-url>"
