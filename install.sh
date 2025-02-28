#!/bin/bash

CONFIG_FILE="/etc/system_status.conf"
SERVICE_FILE="/etc/systemd/system/system-status.service"
CRON_FILE="/etc/cron.d/system-status-cron"
INSTALL_PATH="/usr/local/bin/system-status"

echo "🔧 Installing System Status Monitor..."

# Ask for custom server name
read -p "🖥️ Enter your custom server name: " SERVER_NAME

# Validate numeric input for interval
while true; do
    read -p "⏳ How often should system status be sent? (in minutes): " INTERVAL
    if [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
        break
    else
        echo "❌ Invalid input! Please enter a valid number."
    fi
done

# Ask for Webhook URL
read -p "🔗 Enter your Discord Webhook URL: " WEBHOOK_URL

# Save configuration
echo "SERVER_NAME=\"$SERVER_NAME\"" | sudo tee "$CONFIG_FILE" > /dev/null
echo "INTERVAL=\"$INTERVAL\"" | sudo tee -a "$CONFIG_FILE" > /dev/null
echo "WEBHOOK_URL=\"$WEBHOOK_URL\"" | sudo tee -a "$CONFIG_FILE" > /dev/null

echo "✅ Configuration saved at $CONFIG_FILE"

# Copy main script to /usr/local/bin
sudo cp system-status.sh "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

# Set up cron job
echo "*/$INTERVAL * * * * root /usr/local/bin/system-status" | sudo tee "$CRON_FILE" > /dev/null
sudo chmod 644 "$CRON_FILE"
sudo systemctl restart cron

# Create systemd service
sudo tee "$SERVICE_FILE" > /dev/null <<EOL
[Unit]
Description=System Status Monitor
After=network.target

[Service]
ExecStart=/usr/local/bin/system-status
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the systemd service
sudo systemctl daemon-reload
sudo systemctl enable system-status.service
sudo systemctl start system-status.service

echo "✅ Installation complete! System status will be sent every $INTERVAL minutes."
