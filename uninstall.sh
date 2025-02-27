#!/bin/bash

INSTALL_PATH="/usr/local/bin/system-status"
CONFIG_FILE="/etc/system_status.conf"
CRON_FILE="/etc/cron.d/system-status-cron"
SYSTEMD_SERVICE="/etc/systemd/system/system-status.service"
UNINSTALL_SCRIPT="/usr/local/bin/system-status-uninstall"

# Remove the system status script
echo "🗑️ Removing system status script..."
sudo rm -f "$INSTALL_PATH"

# Remove the configuration file
echo "🗑️ Removing configuration file..."
sudo rm -f "$CONFIG_FILE"

# Remove the cron job
echo "🗑️ Removing cron job..."
sudo rm -f "$CRON_FILE"

# Remove the systemd service
echo "🗑️ Removing systemd service..."
sudo systemctl stop system-status.service
sudo systemctl disable system-status.service
sudo rm -f "$SYSTEMD_SERVICE"
sudo systemctl daemon-reload

# Remove the commands for updating webhook and server name
echo "🗑️ Removing commands for webhook and server name update..."
sudo rm -f /usr/local/bin/system-status-set-webhook
sudo rm -f /usr/local/bin/system-status-set-servername

# Remove the uninstall script
echo "🗑️ Removing uninstall script..."
sudo rm -f "$UNINSTALL_SCRIPT"

# Restart cron service to apply changes
sudo systemctl restart cron

echo "✅ Uninstallation complete!"
