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

# Discord Embed JSON Payload
EMBED=$(cat <<EOF
{
  "username": "Server Monitor",
  "avatar_url": "https://i.imgur.com/j2yF8aN.png",
  "embeds": [{
    "title": "🖥 $HOSTNAME - System Status",
    "color": 5814783,
    "fields": [
      { "name": "🕒 Uptime", "value": "$UPTIME", "inline": true },
      { "name": "💻 CPU Usage", "value": "$CPU_USAGE", "inline": true },
      { "name": "🔥 CPU Temp", "value": "$CPU_TEMP", "inline": true },
      { "name": "🧠 Memory Usage", "value": "$MEMORY_USAGE", "inline": true },
      { "name": "💾 Disk Usage", "value": "$DISK_USAGE", "inline": true },
      { "name": "📊 Load Average", "value": "$LOAD_AVG", "inline": true }
    ],
    "footer": {
      "text": "Last updated",
      "icon_url": "https://i.imgur.com/j2yF8aN.png"
    },
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  }]
}
EOF
)

# Send to Discord
curl -H "Content-Type: application/json" -d "$EMBED" "$WEBHOOK_URL"
