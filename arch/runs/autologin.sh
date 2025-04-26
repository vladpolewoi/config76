#!/bin/bash

set -e

USERNAME="user76"

echo "🔐 Setting up TTY autologin for: $USERNAME"

# Step 1: Create systemd override for getty@tty1
echo "📂 Creating override for getty@tty1..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d

sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USERNAME --noclear %I \$TERM
EOF

# Step 2: Enable autologin service
echo "🟢 Enabling getty@tty1..."
sudo systemctl daemon-reexec
sudo systemctl enable getty@tty1

echo "✅ Autologin on tty1 set for '$USERNAME'"
echo "💡 Reboot to test: 'reboot'"

