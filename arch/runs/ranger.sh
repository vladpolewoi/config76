
#!/bin/bash

# Check if ranger is installed
if ! command -v ranger &>/dev/null; then
  echo "📦 'ranger ' not found. Installing..."

  # Use yay if available, else fall back to pacman
  if command -v yay &>/dev/null; then
    yay -S --noconfirm ranger 
  else
    sudo pacman -S --needed --noconfirm ranger 
  fi

  echo "✅ 'ranger ' installed."
else
  echo "✅ 'ranger ' is already installed."
fi

