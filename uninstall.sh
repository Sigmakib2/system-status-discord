#!/bin/bash

INSTALL_DIR="/usr/local/bin/system-status"
INSTALL_PATH="/usr/local/bin/system-status"
CONFIG_FILE="/etc/system_status.conf"
CRON_FILE="/etc/cron.d/system-status-cron"
SYSTEMD_SERVICE="/etc/systemd/system/system-status.service"
UNINSTALL_SCRIPT="/usr/local/bin/system-status-uninstall"

echo "🗑️ Uninstalling System Status Monitor..."

# Stop and disable systemd service if it exists
if [ -f "$SYSTEMD_SERVICE" ]; then
    echo "🛑 Stopping systemd service..."
    sudo systemctl stop system-status.service
    sudo systemctl disable system-status.service
    sudo rm -f "$SYSTEMD_SERVICE"
    sudo systemctl daemon-reload
fi

# Remove the script directory and installed files
echo "🗑️ Removing installed files..."
sudo rm -rf "$INSTALL_DIR"
sudo rm -f "$INSTALL_PATH"
sudo rm -f "$CONFIG_FILE"
sudo rm -f "$CRON_FILE"
sudo rm -f "$UNINSTALL_SCRIPT"

# Remove system status update commands
sudo rm -f /usr/local/bin/system-status-set-webhook
sudo rm -f /usr/local/bin/system-status-set-servername

# Restart cron service to apply changes
sudo systemctl restart cron

echo "✅ Uninstallation complete! All files and services have been removed."
