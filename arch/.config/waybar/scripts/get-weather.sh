#!/bin/bash
# Waybar weather: Open-Meteo for Chisinau, cached 10 min, Nerd Font Weather Icons.
# WMO weather codes — day/night variants for clear/partly-cloudy.

LAT=47.006
LON=28.858
CACHE_DIR="$HOME/.cache/weather"
CACHE_FILE="$CACHE_DIR/openmeteo.json"
CACHE_LIFETIME=600

API="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,apparent_temperature,weather_code,is_day&timezone=auto"

mkdir -p "$CACHE_DIR"

update_cache() {
  local data
  data=$(curl -sS --max-time 8 "$API")
  if [[ -n "$data" ]] && echo "$data" | jq -e '.current.weather_code' >/dev/null 2>&1; then
    echo "$data" > "$CACHE_FILE"
  fi
}

if [[ -f "$CACHE_FILE" && -s "$CACHE_FILE" ]]; then
  age=$(( $(date +%s) - $(date -r "$CACHE_FILE" +%s) ))
  (( age > CACHE_LIFETIME )) && update_cache
else
  update_cache
fi

if [[ ! -s "$CACHE_FILE" ]] || ! jq -e '.current.weather_code' "$CACHE_FILE" >/dev/null 2>&1; then
  echo $' --'
  exit 0
fi

read -r CODE TEMP IS_DAY < <(
  jq -r '.current | "\(.weather_code) \(.temperature_2m | round) \(.is_day)"' "$CACHE_FILE"
)

# Weather Icons (nf-weather range, U+E300-E3FF)
case "$CODE" in
  0)        # clear sky
    if (( IS_DAY )); then ICON=$''; else ICON=$''; fi ;;
  1)        # mainly clear
    if (( IS_DAY )); then ICON=$''; else ICON=$''; fi ;;
  2)        # partly cloudy
    if (( IS_DAY )); then ICON=$''; else ICON=$''; fi ;;
  3)        ICON=$'' ;;  # overcast
  45)       ICON=$'' ;;  # fog
  48)       ICON=$'' ;;  # depositing rime fog
  51)       ICON=$'' ;;  # light drizzle
  53)       ICON=$'' ;;  # moderate drizzle
  55)       ICON=$'' ;;  # dense drizzle
  56)       ICON=$'' ;;  # light freezing drizzle
  57)       ICON=$'' ;;  # dense freezing drizzle
  61)       ICON=$'' ;;  # slight rain
  63)       ICON=$'' ;;  # moderate rain
  65)       ICON=$'' ;;  # heavy rain
  66)       ICON=$'' ;;  # light freezing rain
  67)       ICON=$'' ;;  # heavy freezing rain
  71)       ICON=$'' ;;  # slight snow
  73)       ICON=$'' ;;  # moderate snow
  75)       ICON=$'' ;;  # heavy snow
  77)       ICON=$'' ;;  # snow grains
  80)       ICON=$'' ;;  # slight rain showers
  81)       ICON=$'' ;;  # moderate rain showers
  82)       ICON=$'' ;;  # violent rain showers
  85)       ICON=$'' ;;  # slight snow showers
  86)       ICON=$'' ;;  # heavy snow showers
  95)       ICON=$'' ;;  # thunderstorm
  96)       ICON=$'' ;;  # thunderstorm w/ slight hail
  99)       ICON=$'' ;;  # thunderstorm w/ heavy hail
  *)        ICON=$'' ;;
esac

echo "$ICON  ${TEMP}°C"
