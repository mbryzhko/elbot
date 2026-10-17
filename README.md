# elbot

## Shell/Telegram monitor (`elbot.sh`)

A dependency-light bash alternative that runs directly on a Raspberry Pi. It reads the
GPIO pin with `raspi-gpio get`, sends the initial state to Telegram on start, and a message
on every change (signal `1` = no electricity, `0` = power OK). Needs `curl` and `raspi-gpio`
(root or `gpio` group).

| Env var | Default | Meaning |
|---|---|---|
| `ELBOT_TELEGRAM_TOKEN` | – (required) | Bot token from @BotFather |
| `ELBOT_TELEGRAM_CHAT_ID` | – (required) | Chat to post to |
| `ELBOT_GPIO_PIN` | `17` | BCM pin number |
| `ELBOT_POLL_INTERVAL_SEC` | `5` | Poll interval in seconds |

```
ELBOT_TELEGRAM_TOKEN=123:abc ELBOT_TELEGRAM_CHAT_ID=42 ./elbot.sh
```

Note: a failed Telegram send is logged and not retried. On Raspberry Pi OS Bookworm
`raspi-gpio` is deprecated in favour of `pinctrl`; only `read_level()` needs changing.

### systemd
1. Check the files

/home/pi/elbot/elbot.env holds plain KEY=value lines. systemd doesn't accept export here.
ELBOT_TELEGRAM_TOKEN=123456:ABC...
ELBOT_TELEGRAM_CHAT_ID=123456789
ELBOT_GPIO_PIN=17
ELBOT_POLL_INTERVAL_SEC=5

/home/pi/elbot/elbot.service should look like this:
[Unit]
Description=Elbot grid monitor
After=network-online.target
Wants=network-online.target

[Service]
User=pi
EnvironmentFile=/home/pi/elbot/elbot.env
ExecStart=/home/pi/elbot/elbot.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
User=pi matters because the pi user is normally in the gpio group, which raspi-gpio needs. Without it the service runs as root, which also works.

2. Set permissions
   chmod +x /home/pi/elbot/elbot.sh
   chmod 600 /home/pi/elbot/elbot.env   # the file holds the bot token

3. Test the script by hand first
   set -a; . /home/pi/elbot/elbot.env; set +a
   /home/pi/elbot/elbot.sh      # Ctrl+C to stop
   You should get the startup message in Telegram.

4. Register the service

Symlink the unit so edits in /home/pi/elbot take effect. systemctl link does this:
sudo systemctl link /home/pi/elbot/elbot.service
sudo systemctl daemon-reload
sudo systemctl enable --now elbot.service
If you'd rather have a copy, use sudo cp /home/pi/elbot/elbot.service /etc/systemd/system/ instead of the link line. You then have to copy it again after every change.

5. Check that it works
   systemctl status elbot.service
   journalctl -u elbot.service -f     # live logs
   The -f log should show initial state: ..., and the Telegram message should arrive.

Day-to-day commands
sudo systemctl restart elbot.service   # after editing elbot.sh or elbot.env
sudo systemctl daemon-reload           # after editing elbot.service, then restart
sudo systemctl disable --now elbot.service   # stop and remove from boot

Troubleshooting
- status=203/EXEC: elbot.sh isn't executable, or the path in ExecStart is wrong.
- Log says "required command not found: raspi-gpio": check which raspi-gpio. If it's missing, you're on Bookworm and need pinctrl instead.
- Log says "cannot read GPIO": run groups pi and make sure gpio is listed, or remove User=pi to run as root.

My README snippet uses /etc/elbot.env and /opt/elbot. I can update it to match /home/pi/elbot if you want.