
#!/bin/bash

# Set URL and cache
URL="https://wttr.in/?format=j1"
CACHE_DIR="$HOME/.cache/weather"
CACHE_FILE="$CACHE_DIR/weather.json"
CACHE_LIFETIME=600  # 10 minutes

mkdir -p "$CACHE_DIR"

update_cache() {
  local data
  data=$(curl -s --max-time 5 "$URL")
  if [[ $(echo "$data" | jq -r '.current_condition[0].weatherCode' 2>/dev/null) != "null" ]]; then
    echo "$data" > "$CACHE_FILE"
  fi
}

# Use cache if fresh
if [[ -f "$CACHE_FILE" ]]; then
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
if [[ ! -f "$CACHE_FILE" ]]; then
  echo " Loading..."
  exit 0
fi

# Read from cache
WEATHER_JSON=$(cat "$CACHE_FILE")

WWO_CODE=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherCode')
TEMP=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].FeelsLikeC')

# Safety fallback
if [[ "$WWO_CODE" == "null" || -z "$WWO_CODE" ]]; then
  echo " Loading..."
  exit 0
fi

# Mappings
declare -A WWO_CODE_MAP=(
  ["113"]="Sunny" ["116"]="PartlyCloudy" ["119"]="Cloudy" ["122"]="VeryCloudy" ["143"]="Fog"
  ["176"]="LightShowers" ["179"]="LightSleetShowers" ["182"]="LightSleet" ["185"]="LightSleet"
  ["200"]="ThunderyShowers" ["227"]="LightSnow" ["230"]="HeavySnow" ["248"]="Fog" ["260"]="Fog"
  ["263"]="LightShowers" ["266"]="LightRain" ["281"]="LightSleet" ["284"]="LightSleet"
  ["293"]="LightRain" ["296"]="LightRain" ["299"]="HeavyShowers" ["302"]="HeavyRain"
  ["305"]="HeavyShowers" ["308"]="HeavyRain" ["311"]="LightSleet" ["314"]="LightSleet"
  ["317"]="LightSleet" ["320"]="LightSnow" ["323"]="LightSnowShowers" ["326"]="LightSnowShowers"
  ["329"]="HeavySnow" ["332"]="HeavySnow" ["335"]="HeavySnowShowers" ["338"]="HeavySnow"
  ["350"]="LightSleet" ["353"]="LightShowers" ["356"]="HeavyShowers" ["359"]="HeavyRain"
  ["362"]="LightSleetShowers" ["365"]="LightSleetShowers" ["368"]="LightSnowShowers"
  ["371"]="HeavySnowShowers" ["374"]="LightSleetShowers" ["377"]="LightSleet"
  ["386"]="ThunderyShowers" ["389"]="ThunderyHeavyRain" ["392"]="ThunderySnowShowers"
  ["395"]="HeavySnowShowers"
)

declare -A WEATHER_SYMBOL=(
  ["Unknown"]="✨" ["Cloudy"]="" ["Fog"]="" ["HeavyRain"]="" ["HeavyShowers"]=""
  ["HeavySnow"]="" ["HeavySnowShowers"]="" ["LightRain"]="" ["LightShowers"]=""
  ["LightSleet"]="" ["LightSleetShowers"]="" ["LightSnow"]="" ["LightSnowShowers"]=""
  ["PartlyCloudy"]="󰖕" ["Sunny"]="" ["ThunderyHeavyRain"]="" ["ThunderyShowers"]=""
  ["ThunderySnowShowers"]="" ["VeryCloudy"]=""
)

# Find condition
CONDITION=${WWO_CODE_MAP[$WWO_CODE]:-Unknown}
ICON=${WEATHER_SYMBOL[$CONDITION]:-"✨"}

# Output
echo "$ICON ${TEMP}°C"

