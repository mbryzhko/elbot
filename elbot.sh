#!/usr/bin/env bash
# Grid electricity monitor: polls a GPIO pin with raspi-gpio and reports to Telegram.
# Signal 1 = no electricity (OFF_GRID), 0 = power OK (ON_GRID).
set -u

VERSION="0.2"
PIN="${ELBOT_GPIO_PIN:-17}"
INTERVAL="${ELBOT_POLL_INTERVAL_SEC:-5}"
TOKEN="${ELBOT_TELEGRAM_TOKEN:-}"
CHAT_ID="${ELBOT_TELEGRAM_CHAT_ID:-}"
LOG_FILE="${TMPDIR:-/tmp}/elbot.log"

log() {
  local msg
  msg="$(date '+%F %T') $*"
  echo "$msg" >&2
  echo "$msg" >> "$LOG_FILE"
}

if [ -z "$TOKEN" ] || [ -z "$CHAT_ID" ]; then
  log "ELBOT_TELEGRAM_TOKEN and ELBOT_TELEGRAM_CHAT_ID must be set"
  exit 1
fi
for cmd in curl raspi-gpio; do
  command -v "$cmd" >/dev/null 2>&1 || { log "required command not found: $cmd"; exit 1; }
done

# Prints the pin level (0/1); prints nothing on read error.
read_level() {
  raspi-gpio get "$PIN" 2>/dev/null | sed -n 's/.*level=\([01]\).*/\1/p'
}

status_of() {
  if [ "$1" = "1" ]; then echo "OFF_GRID"; else echo "ON_GRID"; fi
}

send() {
  local err
  err="$(curl -fsS -m 10 -o /dev/null -X POST \
      "https://api.telegram.org/bot${TOKEN}/sendMessage" \
      --data-urlencode "chat_id=${CHAT_ID}" \
      --data-urlencode "text=$1" 2>&1)"
  if [ $? -ne 0 ]; then
    log "failed to send telegram message: $1 | curl error: $err"
  fi
}

trap 'log "stopping"; exit 0' INT TERM

level=""
until level="$(read_level)"; [ -n "$level" ]; do
  log "cannot read GPIO ${PIN}, retrying"
  sleep "$INTERVAL"
done
state="$(status_of "$level")"
log "Elbot started. initial state: $state. Version: $VERSION"
if [ "$state" = "ON_GRID" ]; then
  send "🤖 Elbot started. Grid power: ON ⚡"
else
  send "🤖 Elbot started. Grid power: OFF 🔌"
fi

while true; do
  sleep "$INTERVAL"
  level="$(read_level)"
  if [ -z "$level" ]; then
    log "cannot read GPIO ${PIN}"
    continue
  fi
  new="$(status_of "$level")"
  if [ "$new" != "$state" ]; then
    state="$new"
    log "state changed: $state"
    if [ "$state" = "ON_GRID" ]; then
      send "⚡ Grid power restored ($(date '+%F %T'))"
    else
      send "🔌 Grid power lost ($(date '+%F %T'))"
    fi
  fi
done
