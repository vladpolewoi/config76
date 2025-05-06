#!/bin/bash

# Check if bun is installed
if ! command -v bun &>/dev/null; then
  echo "📦 'bun ' not found. Installing..."

  curl -fsSL https://bun.sh/install | bash

  echo "✅ 'bun ' installed."
else
  echo "✅ 'bun ' is already installed."
fi


