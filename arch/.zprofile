# Autostart hyprland
if [[ -z $DISPLAY && $(tty) = /dev/tty1 ]]; then
  exec hyprland
fi


