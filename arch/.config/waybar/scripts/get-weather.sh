#!/bin/bash

# Open-Meteo API (free, no key needed)
# Chisinau, Moldova
LAT="47.0105"
LON="28.8638"
URL="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,apparent_temperature,weather_code&timezone=auto"

CACHE_DIR="$HOME/.cache/weather"
CACHE_FILE="$CACHE_DIR/weather.json"
CACHE_LIFETIME=600  # 10 minutes

mkdir -p "$CACHE_DIR"

update_cache() {
  local data
  data=$(curl -s --max-time 5 "$URL")
  if [[ $(echo "$data" | jq -r '.current.weather_code' 2>/dev/null) != "null" ]]; then
    echo "$data" > "$CACHE_FILE"
  fi
}

# Use cache if fresh
if [[ -f "$CACHE_FILE" && -s "$CACHE_FILE" ]]; then
  last_update=$(date -r "$CACHE_FILE" +%s)
  now=$(date +%s)
  age=$((now - last_update))
  if ((age > CACHE_LIFETIME)); then
    update_cache
  fi
else
  update_cache
fi

# If no valid cache, fallback
if [[ ! -f "$CACHE_FILE" || ! -s "$CACHE_FILE" ]]; then
  echo " Loading..."
  exit 0
fi

# Read from cache
WEATHER_JSON=$(cat "$CACHE_FILE")

WMO_CODE=$(echo "$WEATHER_JSON" | jq -r '.current.weather_code')
TEMP=$(echo "$WEATHER_JSON" | jq -r '.current.apparent_temperature' | xargs printf "%.0f")

# Safety fallback
if [[ "$WMO_CODE" == "null" || -z "$WMO_CODE" ]]; then
  echo " Loading..."
  exit 0
fi

# WMO weather code to condition name
get_condition() {
  case $1 in
    0)       echo "clear" ;;
    1)       echo "mostly_clear" ;;
    2)       echo "partly_cloudy" ;;
    3)       echo "overcast" ;;
    45|48)   echo "fog" ;;
    51|53|55) echo "drizzle" ;;
    56|57)   echo "freezing_drizzle" ;;
    61|63)   echo "rain" ;;
    65)      echo "heavy_rain" ;;
    66|67)   echo "freezing_rain" ;;
    71|73)   echo "snow" ;;
    75|77)   echo "heavy_snow" ;;
    80|81)   echo "rain_showers" ;;
    82)      echo "heavy_showers" ;;
    85|86)   echo "snow_showers" ;;
    95)      echo "thunderstorm" ;;
    96|99)   echo "thunderstorm_hail" ;;
    *)       echo "unknown" ;;
  esac
}

CONDITION=$(get_condition "$WMO_CODE")

# Nerd Font icons via printf to preserve glyphs
case "$CONDITION" in
  clear)             ICON=$'\ue30d' ;;
  mostly_clear)      ICON=$'\ue30d' ;;
  partly_cloudy)     ICON=$'\ue302' ;;
  overcast)          ICON=$'\ue312' ;;
  fog)               ICON=$'\ue313' ;;
  drizzle)           ICON=$'\ue319' ;;
  freezing_drizzle)  ICON=$'\ue318' ;;
  rain)              ICON=$'\ue318' ;;
  heavy_rain)        ICON=$'\ue318' ;;
  freezing_rain)     ICON=$'\ue318' ;;
  snow)              ICON=$'\ue31a' ;;
  heavy_snow)        ICON=$'\ue31a' ;;
  rain_showers)      ICON=$'\ue319' ;;
  heavy_showers)     ICON=$'\ue318' ;;
  snow_showers)      ICON=$'\ue31a' ;;
  thunderstorm)      ICON=$'\ue31d' ;;
  thunderstorm_hail) ICON=$'\ue31d' ;;
  *)                 ICON=$'\ue37e' ;;
esac

echo "$ICON  ${TEMP}°C"
