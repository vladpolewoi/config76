#!/bin/bash
# Waybar weather: wttr.in for Chisinau, cached 10 min, Nerd Font Weather Icons.
# WWO codes — full mapping + day/night variants for clear/partly-cloudy.

CITY="Chisinau"
CACHE_DIR="$HOME/.cache/weather"
CACHE_FILE="$CACHE_DIR/weather.json"
CACHE_LIFETIME=600

mkdir -p "$CACHE_DIR"

update_cache() {
  local data
  data=$(curl -sS --max-time 8 "https://wttr.in/${CITY}?format=j1")
  if [[ -n "$data" ]] && echo "$data" | jq -e '.current_condition[0].weatherCode' >/dev/null 2>&1; then
    echo "$data" > "$CACHE_FILE"
  fi
}

if [[ -f "$CACHE_FILE" && -s "$CACHE_FILE" ]]; then
  age=$(( $(date +%s) - $(date -r "$CACHE_FILE" +%s) ))
  (( age > CACHE_LIFETIME )) && update_cache
else
  update_cache
fi

if [[ ! -s "$CACHE_FILE" ]] || ! jq -e '.current_condition[0].weatherCode' "$CACHE_FILE" >/dev/null 2>&1; then
  echo " --"
  exit 0
fi

CODE=$(jq -r '.current_condition[0].weatherCode' "$CACHE_FILE")
TEMP=$(jq -r '.current_condition[0].FeelsLikeC' "$CACHE_FILE")

# Determine day/night from astronomy
to_24h() {  # "06:30 AM" -> 0630 (integer HHMM)
  local t="$1" h m suffix
  h=${t%%:*}; rest=${t#*:}; m=${rest%% *}; suffix=${rest##* }
  h=$((10#$h)); m=$((10#$m))
  [[ "$suffix" == "PM" && $h -lt 12 ]] && h=$((h+12))
  [[ "$suffix" == "AM" && $h -eq 12 ]] && h=0
  printf '%d%02d' "$h" "$m"
}

SUNRISE=$(to_24h "$(jq -r '.weather[0].astronomy[0].sunrise' "$CACHE_FILE")")
SUNSET=$(to_24h  "$(jq -r '.weather[0].astronomy[0].sunset'  "$CACHE_FILE")")
NOW_HHMM=$(date +%H%M | sed 's/^0*//')
NOW_HHMM=${NOW_HHMM:-0}

IS_DAY=1
(( NOW_HHMM < SUNRISE || NOW_HHMM > SUNSET )) && IS_DAY=0

# Weather Icons (nf-weather range, U+E300-E37F)
case "$CODE" in
  113)  # clear / sunny
    if (( IS_DAY )); then ICON=$''; else ICON=$''; fi ;;
  116)  # partly cloudy
    if (( IS_DAY )); then ICON=$''; else ICON=$''; fi ;;
  119)  ICON=$'' ;;  # cloudy
  122)  ICON=$'' ;;  # overcast
  143)  ICON=$'' ;;  # mist
  248)  ICON=$'' ;;  # fog
  260)  ICON=$'' ;;  # freezing fog
  176)  ICON=$'' ;;  # patchy rain
  263)  ICON=$'' ;;  # patchy light drizzle
  266)  ICON=$'' ;;  # light drizzle
  281)  ICON=$'' ;;  # freezing drizzle
  284)  ICON=$'' ;;  # heavy freezing drizzle
  293)  ICON=$'' ;;  # patchy light rain
  296)  ICON=$'' ;;  # light rain
  299)  ICON=$'' ;;  # moderate rain at times
  302)  ICON=$'' ;;  # moderate rain
  305)  ICON=$'' ;;  # heavy rain at times
  308)  ICON=$'' ;;  # heavy rain
  311)  ICON=$'' ;;  # light freezing rain
  314)  ICON=$'' ;;  # moderate/heavy freezing rain
  317)  ICON=$'' ;;  # light sleet
  320)  ICON=$'' ;;  # moderate/heavy sleet
  323)  ICON=$'' ;;  # patchy light snow
  326)  ICON=$'' ;;  # light snow
  329)  ICON=$'' ;;  # patchy moderate snow
  332)  ICON=$'' ;;  # moderate snow
  335)  ICON=$'' ;;  # patchy heavy snow
  338)  ICON=$'' ;;  # heavy snow
  350)  ICON=$'' ;;  # ice pellets
  353)  ICON=$'' ;;  # light rain shower
  356)  ICON=$'' ;;  # mod/heavy rain shower
  359)  ICON=$'' ;;  # torrential rain shower
  362)  ICON=$'' ;;  # light sleet showers
  365)  ICON=$'' ;;  # mod/heavy sleet showers
  368)  ICON=$'' ;;  # light snow showers
  371)  ICON=$'' ;;  # mod/heavy snow showers
  374)  ICON=$'' ;;  # light ice pellet showers
  377)  ICON=$'' ;;  # mod/heavy ice pellet showers
  179)  ICON=$'' ;;  # patchy snow nearby
  182)  ICON=$'' ;;  # patchy sleet nearby
  185)  ICON=$'' ;;  # patchy freezing drizzle
  200)  ICON=$'' ;;  # thundery outbreaks
  386)  ICON=$'' ;;  # patchy light rain w/ thunder
  389)  ICON=$'' ;;  # mod/heavy rain w/ thunder
  392)  ICON=$'' ;;  # patchy light snow w/ thunder
  395)  ICON=$'' ;;  # mod/heavy snow w/ thunder
  227)  ICON=$'' ;;  # blowing snow
  230)  ICON=$'' ;;  # blizzard
  *)    ICON=$'' ;;
esac

echo "$ICON  ${TEMP}°C"
