#!/bin/bash

bluetoothctl power on > /dev/null

SCAN_LABEL="🔍 Scan for new devices"

pick_menu() {
    mapfile -t paired < <(bluetoothctl devices Paired | awk '{print $2 " " substr($0, index($0,$3))}')
    printf '%s\n' "${paired[@]}" | cut -d' ' -f2- | wofi --dmenu --prompt="🎧 Bluetooth"
}

chosen=$(pick_menu)
[ -z "$chosen" ] && exit 0

if [ "$chosen" = "$SCAN_LABEL" ]; then
    notify-send "🔵 Scanning..." "5s"
    bluetoothctl scan on & scan_pid=$!
    sleep 5
    kill "$scan_pid" 2>/dev/null
    bluetoothctl scan off > /dev/null

    mapfile -t devices < <(bluetoothctl devices | awk '{print $2 " " substr($0, index($0,$3))}')
    chosen=$(printf '%s\n' "${devices[@]}" | cut -d' ' -f2- | wofi --dmenu --prompt="🔎 Scan & Connect")
    [ -z "$chosen" ] && exit 0
    mac=$(printf '%s\n' "${devices[@]}" | grep -F "$chosen" | cut -d' ' -f1)
else
    mapfile -t paired < <(bluetoothctl devices Paired | awk '{print $2 " " substr($0, index($0,$3))}')
    mac=$(printf '%s\n' "${paired[@]}" | grep -F "$chosen" | cut -d' ' -f1)
fi

[ -z "$mac" ] && { notify-send "🔴 Device not found"; exit 1; }

# Disconnect any other connected BT audio device so it doesn't keep
# fighting for the default sink alongside the one we're switching to.
mapfile -t connected < <(bluetoothctl devices Connected | awk '{print $2}')
for other in "${connected[@]}"; do
    [ "$other" = "$mac" ] && continue
    bluetoothctl disconnect "$other" > /dev/null
done

# Pair/trust only if needed - re-pairing an already paired device is
# noisy and can fail with a benign-looking error.
if ! bluetoothctl info "$mac" | grep -q "Paired: yes"; then
    bluetoothctl pair "$mac" > /dev/null
    bluetoothctl trust "$mac" > /dev/null
fi

bluetoothctl connect "$mac" > /dev/null

if ! bluetoothctl info "$mac" | grep -q "Connected: yes"; then
    notify-send "🔴 Failed to connect to $chosen"
    exit 1
fi

# Bluetooth-level connect succeeding doesn't mean PipeWire has routed
# audio there - it just creates the sink, still on whatever was default
# before. Wait for the sink node to show up, then actually switch to it.
sink="bluez_output.${mac//:/_}.1"

for _ in $(seq 1 10); do
    pactl list sinks short 2>/dev/null | grep -q "$sink" && break
    sleep 0.5
done

if ! pactl list sinks short 2>/dev/null | grep -q "$sink"; then
    notify-send "🟡 Connected to $chosen" "no audio sink appeared - is it a headset?"
    exit 0
fi

pactl set-default-sink "$sink"

# set-default-sink only affects future streams; move anything already
# playing (Spotify, browser, etc.) onto the new sink right now too.
pactl list sink-inputs short | cut -f1 | while read -r input; do
    pactl move-sink-input "$input" "$sink" > /dev/null 2>&1
done

notify-send "🟢 Connected to $chosen" "audio switched"
