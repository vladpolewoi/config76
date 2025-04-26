#!/bin/bash

# Start scanning
bluetoothctl power on
bluetoothctl scan on &
sleep 5
bluetoothctl scan off

# Get list of visible devices
mapfile -t devices < <(bluetoothctl devices | awk '{print $2 " " substr($0, index($0,$3))}')

# If no devices found
if [ ${#devices[@]} -eq 0 ]; then
    notify-send "🔴 No Bluetooth devices found"
    exit 1
fi

# Show device names in wofi
chosen=$(printf '%s\n' "${devices[@]}" | cut -d' ' -f2- | wofi --dmenu --prompt="🔎 Scan & Connect")

# Exit if nothing selected
[ -z "$chosen" ] && exit 0

# Get MAC from chosen name
mac=$(printf '%s\n' "${devices[@]}" | grep "$chosen" | cut -d' ' -f1)

# Attempt to pair, trust, and connect
{
  bluetoothctl pair "$mac"
  bluetoothctl trust "$mac"
  bluetoothctl connect "$mac"
} > /dev/null

# Confirm connection
if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
  notify-send "🟢 Connected to $chosen"
else
  notify-send "🔴 Failed to connect to $chosen"
fi

