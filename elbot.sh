#!/usr/bin/env bash
# Grid electricity monitor: polls a GPIO pin with raspi-gpio and reports to Telegram.
# Signal 1 = no electricity (OFF_GRID), 0 = power OK (ON_GRID).
# Also answers "/status" messages from allowed chats with the current state.
set -u

VERSION="0.3"
PIN="${ELBOT_GPIO_PIN:-17}"
INTERVAL="${ELBOT_POLL_INTERVAL_SEC:-5}"
TOKEN="${ELBOT_TELEGRAM_TOKEN:-}"
CHAT_ID="${ELBOT_TELEGRAM_CHAT_ID:-}"
ALLOWED_CHAT_IDS="${ELBOT_ALLOWED_CHAT_IDS:-$CHAT_ID}"
LOG_FILE="${TMPDIR:-/tmp}/elbot.log"
STATE_FILE="${TMPDIR:-/tmp}/elbot_state"
OFFSET_FILE="${TMPDIR:-/tmp}/elbot_offset"

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
for cmd in curl raspi-gpio jq; do
  command -v "$cmd" >/dev/null 2>&1 || { log "required command not found: $cmd"; exit 1; }
done

# Prints the pin level (0/1); prints nothing on read error.
read_level() {
  raspi-gpio get "$PIN" 2>/dev/null | sed -n 's/.*level=\([01]\).*/\1/p'
}

status_of() {
  if [ "$1" = "1" ]; then echo "OFF_GRID"; else echo "ON_GRID"; fi
}

write_state() {
  echo "$1" > "$STATE_FILE"
}

send_to() {
  local chat_id="$1" text="$2" err
  err="$(curl -fsS -m 10 -o /dev/null -X POST \
      "https://api.telegram.org/bot${TOKEN}/sendMessage" \
      --data-urlencode "chat_id=${chat_id}" \
      --data-urlencode "text=${text}" 2>&1)"
  if [ $? -ne 0 ]; then
    log "failed to send telegram message: $text | curl error: $err"
  fi
}

send() {
  send_to "$CHAT_ID" "$1"
}

is_allowed_chat() {
  case ",${ALLOWED_CHAT_IDS}," in
    *",${1},"*) return 0 ;;
    *) return 1 ;;
  esac
}

reply_status() {
  local chat_id="$1" saved_state msg
  saved_state="$(cat "$STATE_FILE" 2>/dev/null)"
  case "${saved_state:-}" in
    ON_GRID) msg="⚡ Grid power: ON" ;;
    OFF_GRID) msg="🔌 Grid power: OFF" ;;
    *) msg="❓ Grid power state unknown" ;;
  esac
  send_to "$chat_id" "$msg"
}

# Fetches pending Telegram messages (non-blocking) and answers /status queries.
check_updates() {
  local resp count i update_id chat_id text
  resp="$(curl -fsS -m 10 "https://api.telegram.org/bot${TOKEN}/getUpdates?timeout=0&offset=${OFFSET}" 2>&1)"
  if [ $? -ne 0 ]; then
    log "failed to fetch telegram updates: $resp"
    return
  fi
  count="$(echo "$resp" | jq '.result | length' 2>/dev/null)"
  [ -z "$count" ] && return
  for ((i = 0; i < count; i++)); do
    update_id="$(echo "$resp" | jq -r ".result[$i].update_id")"
    chat_id="$(echo "$resp" | jq -r ".result[$i].message.chat.id // empty")"
    text="$(echo "$resp" | jq -r ".result[$i].message.text // empty")"
    OFFSET=$((update_id + 1))
    echo "$OFFSET" > "$OFFSET_FILE"
    [ -z "$chat_id" ] && continue
    if ! is_allowed_chat "$chat_id"; then
      log "ignoring message from unauthorized chat $chat_id"
      continue
    fi
    case "$text" in
      /status*|status) reply_status "$chat_id" ;;
    esac
  done
}

trap 'log "stopping"; exit 0' INT TERM

OFFSET=0
[ -f "$OFFSET_FILE" ] && OFFSET="$(cat "$OFFSET_FILE")"

level=""
until level="$(read_level)"; [ -n "$level" ]; do
  log "cannot read GPIO ${PIN}, retrying"
  sleep "$INTERVAL"
done
state="$(status_of "$level")"
write_state "$state"
log "Elbot started. initial state: $state. Version: $VERSION"
if [ "$state" = "ON_GRID" ]; then
  send "🤖 Elbot started. Grid power: ON ⚡"
else
  send "🤖 Elbot started. Grid power: OFF 🔌"
fi

while true; do
  sleep "$INTERVAL"
  check_updates
  level="$(read_level)"
  if [ -z "$level" ]; then
    log "cannot read GPIO ${PIN}"
    continue
  fi
  new="$(status_of "$level")"
  if [ "$new" != "$state" ]; then
    state="$new"
    write_state "$state"
    log "state changed: $state"
    if [ "$state" = "ON_GRID" ]; then
      send "⚡ Grid power restored ($(date '+%F %T'))"
    else
      send "🔌 Grid power lost ($(date '+%F %T'))"
    fi
  fi
done
