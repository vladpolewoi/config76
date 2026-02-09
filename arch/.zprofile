# Qt dark theme
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=Adwaita-Dark

# Autostart hyprland
if [[ -z $DISPLAY && $(tty) = /dev/tty1 ]]; then
  exec start-hyprland
fi

