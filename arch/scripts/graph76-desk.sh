#!/bin/bash
# graph76 Desk popup: a Chrome --app window living on special:tasks.
#   graph76-desk.sh            toggle (Super+T); launches the window if it's gone
#   graph76-desk.sh --preload  login: wait for the web unit, open the window hidden
# Window rules for class chrome-localhost__-Default are in hyprland.lua.
# Servers are systemd user units (graph76-api, graph76-web) from ~/code/graph76-new/tools/systemd.

URL="http://localhost:5173"
CLASS="chrome-localhost__-Default"
PROFILE="$HOME/.local/share/graph76-chrome"

running() {
    hyprctl clients -j | grep -q "\"class\": \"$CLASS\""
}

launch() {
    setsid google-chrome-stable --user-data-dir="$PROFILE" --no-first-run \
        --no-default-browser-check --app="$URL" >/dev/null 2>&1 < /dev/null &
}

if [ "$1" = "--preload" ]; then
    for _ in $(seq 60); do
        curl -fs -o /dev/null "$URL" && break
        sleep 0.5
    done
    running || launch
    exit 0
fi

running || launch
hyprctl dispatch 'hl.dsp.workspace.toggle_special("tasks")' >/dev/null
