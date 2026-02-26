#!/bin/bash

set -e

header() { echo "==== $1 ===="; }; success() { echo "  ✓ $1"; }; skip() { echo "  - SKIP: $1"; }; info() { echo "  $1"; }

header "Remapping Caps Lock → Escape"

plist_path="$HOME/Library/LaunchAgents/com.local.KeyRemapping.plist"

# Apply immediately
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}' >/dev/null

success "Caps Lock → Escape (current session)"

# Install LaunchAgent for persistence across reboots
if [[ -f "$plist_path" ]]; then
  skip "LaunchAgent already exists"
else
  mkdir -p "$HOME/Library/LaunchAgents"
  cat > "$plist_path" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.local.KeyRemapping</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/hidutil</string>
    <string>property</string>
    <string>--set</string>
    <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
PLIST
  success "LaunchAgent installed at $plist_path"
fi

info "Caps Lock is now Escape system-wide (persists after reboot)"

# ── Mission Control: Cmd+7/8/9/0 → Spaces 1-4 ──
header "Setting Cmd+7/8/9/0 → Switch Spaces 1-4"

# Symbolic hotkey IDs: 118=Space1, 119=Space2, 120=Space3, 121=Space4
# Parameters: (ASCII code, virtual keycode, modifier flags)
# Cmd = 1048576 (0x100000)
# 7: ascii=55 keycode=26 | 8: ascii=56 keycode=28
# 9: ascii=57 keycode=25 | 0: ascii=48 keycode=29

defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 118 \
  '<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>55</integer><integer>26</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>'

defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 119 \
  '<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>56</integer><integer>28</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>'

defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 120 \
  '<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>57</integer><integer>25</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>'

defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 121 \
  '<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>48</integer><integer>29</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>'

# Activate changes
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

success "Cmd+7 → Space 1"
success "Cmd+8 → Space 2"
success "Cmd+9 → Space 3"
success "Cmd+0 → Space 4"

# ── Move window to space: Cmd+Shift+7/8/9/0 ──
# Note: macOS has no native "Move window to Desktop X" shortcuts.
# This is handled by skhd + yabai instead (see .config/skhd/skhdrc).
info "Cmd+Shift+7/8/9/0 → Move to Space 1-4 (via skhd + yabai)"
