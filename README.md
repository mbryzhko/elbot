# elbot

A lightweight electricity grid monitor for Raspberry Pi. It polls a GPIO pin with `raspi-gpio` and sends a Telegram message whenever the grid power is lost or restored.

- Signal `1` on the pin → grid is **OFF** (no electricity)
- Signal `0` on the pin → grid is **ON** (power OK)

Runs as a systemd service and survives reboots.

## Requirements

- Raspberry Pi with `raspi-gpio` and `curl` installed
- A Telegram bot token and a chat ID to send notifications to

## Installation

Download and run the installer:

```bash
wget -qO install.sh https://raw.githubusercontent.com/mbryzhko/elbot/main/install.sh
sudo bash install.sh
```

The installer will:
1. Copy `elbot.sh` to `/home/pi/elbot/`
2. Prompt for your Telegram bot token and chat ID
3. Register and start the `elbot` systemd service

### Update

To update to the latest version without touching your credentials:

```bash
wget -qO install.sh https://raw.githubusercontent.com/mbryzhko/elbot/main/install.sh
sudo bash install.sh --update
```

## Configuration

Settings are read from `/home/pi/elbot/elbot.env`:

| Variable                  | Default | Description                        |
|---------------------------|---------|------------------------------------|
| `ELBOT_TELEGRAM_TOKEN`    | *(required)* | Telegram bot token            |
| `ELBOT_TELEGRAM_CHAT_ID`  | *(required)* | Telegram chat ID              |
| `ELBOT_GPIO_PIN`          | `17`    | BCM pin number to monitor          |
| `ELBOT_POLL_INTERVAL_SEC` | `5`     | Polling interval in seconds        |

After editing the file, restart the service:

```bash
sudo systemctl restart elbot
```

## Service management

```bash
sudo systemctl status elbot    # check status
sudo journalctl -u elbot -f    # follow logs
sudo systemctl stop elbot      # stop
sudo systemctl disable elbot   # disable autostart
```
