#!/bin/bash

INSTALL_PATH="/usr/local/bin/system-status"
CONFIG_FILE="/etc/system_status.conf"
CRON_FILE="/etc/cron.d/system-status-cron"
SERVICE_FILE="/etc/systemd/system/system-status.service"
UNINSTALL_SCRIPT="/usr/local/bin/system-status-uninstall"

echo "🗑️ Uninstalling System Status Monitor..."

# Stop and disable systemd service
if [ -f "$SERVICE_FILE" ]; then
    sudo systemctl stop system-status.service
    sudo systemctl disable system-status.service
    sudo rm -f "$SERVICE_FILE"
    sudo systemctl daemon-reload
fi

# Remove cron job
sudo rm -f "$CRON_FILE"
sudo systemctl restart cron

# Remove script & config
sudo rm -f "$INSTALL_PATH"
sudo rm -f "$CONFIG_FILE"
sudo rm -f "$UNINSTALL_SCRIPT"

echo "✅ Uninstallation complete!"
