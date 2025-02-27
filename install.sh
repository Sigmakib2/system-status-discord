#!/bin/bash

INSTALL_PATH="/usr/local/bin/system-status"
CONFIG_FILE="/etc/system_status.conf"
CRON_FILE="/etc/cron.d/system-status-cron"
UNINSTALL_SCRIPT="/usr/local/bin/system-status-uninstall"
SYSTEMD_SERVICE="/etc/systemd/system/system-status.service"

echo "🔧 Installing system-status..."

# Ask for Discord Webhook URL
read -p "📡 Enter your Discord Webhook URL: " WEBHOOK_URL

# Ask for custom server name
read -p "🖥️ Enter your custom server name: " SERVER_NAME

# Ask for update interval (in minutes)
read -p "⏳ How often should system status be sent? (in minutes): " INTERVAL

# Validate interval input
if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
    echo "❌ Invalid input! Please enter a number."
    exit 1
fi

# Save configuration
echo "WEBHOOK_URL=$WEBHOOK_URL" | sudo tee "$CONFIG_FILE" > /dev/null
echo "SERVER_NAME=$SERVER_NAME" | sudo tee -a "$CONFIG_FILE" > /dev/null

# Move script to /usr/local/bin
sudo cp system_status.sh "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

# Create a cron job (this part is optional, but leaves it in case you prefer cron)
echo "*/$INTERVAL * * * * root /usr/local/bin/system-status" | sudo tee "$CRON_FILE" > /dev/null
sudo chmod 644 "$CRON_FILE"
sudo systemctl restart cron  # Restart cron service

# Create a command for updating the webhook URL
echo '#!/bin/bash' | sudo tee /usr/local/bin/system-status-set-webhook > /dev/null
echo "sed -i \"s|WEBHOOK_URL=.*|WEBHOOK_URL=\$1|\" $CONFIG_FILE" | sudo tee -a /usr/local/bin/system-status-set-webhook > /dev/null
sudo chmod +x /usr/local/bin/system-status-set-webhook

# Create a command for updating the server name
echo '#!/bin/bash' | sudo tee /usr/local/bin/system-status-set-servername > /dev/null
echo "sed -i \"s|SERVER_NAME=.*|SERVER_NAME=\$1|\" $CONFIG_FILE" | sudo tee -a /usr/local/bin/system-status-set-servername > /dev/null
sudo chmod +x /usr/local/bin/system-status-set-servername

# Create the uninstall script
echo '#!/bin/bash' | sudo tee "$UNINSTALL_SCRIPT" > /dev/null
sudo cp uninstall.sh "$UNINSTALL_SCRIPT"
sudo chmod +x "$UNINSTALL_SCRIPT"

# Create systemd service file to run the script on boot
echo "[Unit]
Description=System Status Script
After=network.target

[Service]
ExecStart=$INSTALL_PATH
Restart=always
User=root
StandardOutput=journal
StandardError=journal
WorkingDirectory=/root/

[Install]
WantedBy=multi-user.target" | sudo tee "$SYSTEMD_SERVICE" > /dev/null

# Enable and start the systemd service
sudo systemctl daemon-reload
sudo systemctl enable system-status.service
sudo systemctl start system-status.service

echo "✅ Installation complete!"
echo "🚀 System status will be sent every $INTERVAL minutes."
echo "📢 Run 'system-status' to manually send status to Discord."
echo "🔄 To change the webhook, use: system-status-set-webhook <new-webhook-url>"
echo "🖥️ To change the server name, use: system-status-set-servername <new-server-name>"
echo "🗑️ To uninstall the tool, use: system-status-uninstall"
