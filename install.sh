#!/usr/bin/env bash
# Elbot installer / updater
# Usage:
#   bash install.sh          – first install (prompts for Telegram credentials)
#   bash install.sh --update – update script + service unit, keep existing elbot.env
set -euo pipefail

INSTALL_DIR="/home/pi/elbot"
SERVICE_NAME="elbot"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
SCRIPT_URL="https://raw.githubusercontent.com/mbryzhko/elbot/main/elbot.sh"
SERVICE_URL="https://raw.githubusercontent.com/mbryzhko/elbot/main/elbot.service"

UPDATE_ONLY=false
if [ "${1:-}" = "--update" ]; then
  UPDATE_ONLY=true
fi

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root (use sudo)." >&2
    exit 1
  fi
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Required command not found: $1" >&2; exit 1; }
}

require_root
require_cmd curl
require_cmd systemctl

echo "==> Creating install directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

echo "==> Downloading elbot.sh"
curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/elbot.sh"
chmod +x "$INSTALL_DIR/elbot.sh"

echo "==> Downloading service unit"
curl -fsSL "$SERVICE_URL" -o "$SERVICE_FILE"

if ! $UPDATE_ONLY; then
  ENV_FILE="$INSTALL_DIR/elbot.env"

  if [ -f "$ENV_FILE" ]; then
    echo "==> $ENV_FILE already exists – keeping it (run with --update to skip credential prompts)"
  else
    echo ""
    echo "==> Telegram credentials setup"
    read -rp "  Telegram bot token : " token
    read -rp "  Telegram chat ID   : " chat_id
    cat > "$ENV_FILE" <<EOF
ELBOT_TELEGRAM_TOKEN=${token}
ELBOT_TELEGRAM_CHAT_ID=${chat_id}
EOF
    chmod 600 "$ENV_FILE"
    echo "==> Credentials written to $ENV_FILE"
  fi
fi

echo "==> Reloading systemd"
systemctl daemon-reload

if systemctl is-active --quiet "$SERVICE_NAME"; then
  echo "==> Restarting $SERVICE_NAME"
  systemctl restart "$SERVICE_NAME"
else
  echo "==> Enabling and starting $SERVICE_NAME"
  systemctl enable --now "$SERVICE_NAME"
fi

echo ""
echo "Done. Check status with: sudo systemctl status $SERVICE_NAME"
