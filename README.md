# 🚀 System Status to Discord

A simple Bash script that collects system information and sends it to a Discord channel via webhook. Easily installable and configurable on any Linux server.

## 📥 Installation
```bash
git clone https://github.com/Sigmakib2/system-status-discord.git
cd system-status-discord
chmod +x install.sh
sudo ./install.sh
```


system-status-discord/
├── install.sh                # Installation script
├── system-status.sh          # Main script to send system status
├── uninstall.sh              # Uninstall script
├── system-status.service     # Systemd service file
└── README.md                 # Documentation