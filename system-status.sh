#!/bin/bash

CONFIG_FILE="/etc/system_status.conf"

# Load config
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "❌ Config file not found!"
    exit 1
fi

# Get system info
HOSTNAME="$SERVER_NAME"
UPTIME=$(uptime -p)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')%
CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print $1/1000}')°C
MEMORY_USAGE=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
LOAD_AVG=$(cat /proc/loadavg | awk '{print $1, $2, $3}')

# Format message
MESSAGE="🖥 $HOSTNAME Status\n\n"
MESSAGE+="🔹 **Uptime:** $UPTIME\n"
MESSAGE+="💻 **CPU Usage:** $CPU_USAGE\n"
[ -n "$CPU_TEMP" ] && MESSAGE+="🔥 **CPU Temp:** $CPU_TEMP\n"
MESSAGE+="🧠 **Memory Usage:** $MEMORY_USAGE\n"
MESSAGE+="💾 **Disk Usage:** $DISK_USAGE\n"
MESSAGE+="📊 **Load Average:** $LOAD_AVG"

# Send to Discord
PAYLOAD=$(jq -n --arg msg "$MESSAGE" '{content: $msg}')
curl -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"
