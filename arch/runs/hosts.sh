#!/bin/bash

set -e

echo "=-=-=-=- Setting up /etc/hosts -=-=-=-="

HOSTS_ENTRIES="
127.0.0.1 calendar-app.dsd.md
127.0.0.1 calendar-app.r7-office.ru
127.0.0.1 admin-app.r7-office.ru
127.0.0.1 admin-app.r7.ru
127.0.0.1 admin-app.dsd.md
"

for entry in $HOSTS_ENTRIES; do
  : # placeholder for loop
done

# Add entries if not already present
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  if ! grep -qF "$line" /etc/hosts; then
    echo "$line" | sudo tee -a /etc/hosts > /dev/null
    echo "Added: $line"
  else
    echo "Already exists: $line"
  fi
done <<< "$HOSTS_ENTRIES"

echo "=-=-=-=- /etc/hosts setup complete -=-=-=-="
