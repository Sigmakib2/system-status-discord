#!/bin/bash

INSTALL_PATH="/usr/local/bin/system-status"
CONFIG_FILE="/etc/system_status.conf"
SERVICE_FILE="/etc/systemd/system/system-status.service"
TIMER_FILE="/etc/systemd/system/system-status.timer"
UNINSTALL_SCRIPT="/usr/local/bin/system-status-uninstall"

echo "🗑️ Uninstalling System Status Monitor..."

# Stop and disable services
if [ -f "$TIMER_FILE" ]; then
    sudo systemctl stop system-status.timer
    sudo systemctl disable system-status.timer
    sudo rm -f "$TIMER_FILE"
fi

if [ -f "$SERVICE_FILE" ]; then
    sudo systemctl stop system-status.service
    sudo systemctl disable system-status.service
    sudo rm -f "$SERVICE_FILE"
fi

sudo systemctl daemon-reload

# Remove installed files
sudo rm -f "$INSTALL_PATH"
sudo rm -f "$CONFIG_FILE"
sudo rm -f "$UNINSTALL_SCRIPT"

echo "✅ Uninstallation complete!"
