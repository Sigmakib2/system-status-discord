#!/bin/bash

CONFIG_FILE="/etc/system_status.conf"
SERVICE_FILE="/etc/systemd/system/system-status.service"
TIMER_FILE="/etc/systemd/system/system-status.timer"
INSTALL_PATH="/usr/local/bin/system-status"
UNINSTALL_SCRIPT="/usr/local/bin/system-status-uninstall"

echo "🔧 Installing System Status Monitor..."

# Ask for custom server name
read -p "🖥️ Enter your custom server name: " SERVER_NAME

# Ask for time unit selection
echo "Select time unit for the update interval:"
echo "1) Seconds"
echo "2) Minutes"
echo "3) Hours"
while true; do
    read -p "Enter your choice (1/2/3): " UNIT_CHOICE
    case "$UNIT_CHOICE" in
        1) TIME_UNIT="s"; UNIT_LABEL="seconds"; break;;
        2) TIME_UNIT="min"; UNIT_LABEL="minutes"; break;;
        3) TIME_UNIT="h"; UNIT_LABEL="hours"; break;;
        *) echo "❌ Invalid choice! Please enter 1, 2, or 3.";;
    esac
done

# Ask for numeric interval value
while true; do
    read -p "⏳ How many $UNIT_LABEL between each system status update? " INTERVAL
    if [[ "$INTERVAL" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        break
    else
        echo "❌ Invalid input! Please enter a valid number."
    fi
done

# Ask for Webhook URL
read -p "🔗 Enter your Discord Webhook URL: " WEBHOOK_URL

# Compute timer interval string for systemd timer (e.g., "30s", "5min", "1h")
TIMER_INTERVAL="${INTERVAL}${TIME_UNIT}"

# Save configuration
echo "SERVER_NAME=\"$SERVER_NAME\"" | sudo tee "$CONFIG_FILE" > /dev/null
echo "TIMER_INTERVAL=\"$TIMER_INTERVAL\"" | sudo tee -a "$CONFIG_FILE" > /dev/null
echo "WEBHOOK_URL=\"$WEBHOOK_URL\"" | sudo tee -a "$CONFIG_FILE" > /dev/null

echo "✅ Configuration saved at $CONFIG_FILE"

# Copy main script to /usr/local/bin
sudo cp system-status.sh "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

# Create systemd service file for the status script
sudo tee "$SERVICE_FILE" > /dev/null <<EOL
[Unit]
Description=System Status Monitor Service
After=network.target

[Service]
ExecStart=$INSTALL_PATH
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

# Create systemd timer file using the computed interval
sudo tee "$TIMER_FILE" > /dev/null <<EOL
[Unit]
Description=Timer for System Status Monitor

[Timer]
OnBootSec=$TIMER_INTERVAL
OnUnitActiveSec=$TIMER_INTERVAL
Persistent=true

[Install]
WantedBy=timers.target
EOL

# Reload systemd and enable/start the timer
sudo systemctl daemon-reload
sudo systemctl enable system-status.timer
sudo systemctl start system-status.timer

# Create uninstall script
sudo cp uninstall.sh "$UNINSTALL_SCRIPT"
sudo chmod +x "$UNINSTALL_SCRIPT"

echo "✅ Installation complete! System status will be sent every $INTERVAL $UNIT_LABEL."
echo "📢 Run 'system-status' to manually send status to Discord."
echo "🗑️ To uninstall the tool, run: sudo system-status-uninstall"
