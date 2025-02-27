#!/bin/bash

CONFIG_FILE="/etc/system_status.conf"

# Load Webhook URL and Server Name
source "$CONFIG_FILE"

# Get system information
HOSTNAME=$(hostname)
UPTIME=$(uptime -p)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4"%"}')
CPU_TEMP=$(sensors | grep 'Package id 0:' | awk '{print $4}')
MEMORY_USAGE=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
LOAD_AVERAGE=$(uptime | awk -F'load average:' '{ print $2 }')

# Format message
MESSAGE="🖥 **$SERVER_NAME Status**\n\n"
MESSAGE+="🔹 **Hostname:** $HOSTNAME\n"
MESSAGE+="🕒 **Uptime:** $UPTIME\n"
MESSAGE+="💻 **CPU Usage:** $CPU_USAGE\n"
MESSAGE+="🔥 **CPU Temp:** $CPU_TEMP\n"
MESSAGE+="🧠 **Memory Usage:** $MEMORY_USAGE\n"
MESSAGE+="💾 **Disk Usage:** $DISK_USAGE\n"
MESSAGE+="📊 **Load Average:** $LOAD_AVERAGE"

# Send to Discord
curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" "$WEBHOOK_URL"
