#!/bin/bash

CONFIG_FILE="/etc/system_status.conf"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file not found! Please set your webhook using: system-status set-webhook <URL>"
    exit 1
fi

WEBHOOK_URL=$(cat "$CONFIG_FILE")

# Collect system information
HOSTNAME=$(hostname)
UPTIME=$(uptime -p)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4"%"}')
MEMORY_USAGE=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
LOAD_AVERAGE=$(awk '{print $1, $2, $3}' /proc/loadavg)
TEMP=$(sensors | awk '/^Package id 0:/ {print $4}')

# Format message with Discord Markdown
MESSAGE="**🖥 Ubuntu Server Status**\n"
MESSAGE+="\`\`\`\n"  # Start code block
MESSAGE+="🔹 Hostname: $HOSTNAME\n"
MESSAGE+="🕒 Uptime: $UPTIME\n"
MESSAGE+="💻 CPU Usage: $CPU_USAGE\n"
MESSAGE+="🔥 CPU Temp: $TEMP\n"
MESSAGE+="🧠 Memory Usage: $MEMORY_USAGE\n"
MESSAGE+="💾 Disk Usage: $DISK_USAGE\n"
MESSAGE+="📊 Load Average: $LOAD_AVERAGE\n"
MESSAGE+="\`\`\`"  # End code block

# Escape newlines for JSON
ESCAPED_MESSAGE=$(echo -e "$MESSAGE" | jq -Rsa .)

# Send message to Discord
curl -H "Content-Type: application/json" -X POST -d "{\"content\": $ESCAPED_MESSAGE}" "$WEBHOOK_URL"
