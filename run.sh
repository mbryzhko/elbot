#!/usr/bin/env bash
set -euo pipefail

IMAGE_REPO="ghcr.io/mbryzhko/elbot/elbot"
IMAGE="${IMAGE_REPO}:${ELBOT_VERSION:-latest}"
NAME="elbot"

ELBOT_GPIO_PIN="${ELBOT_GPIO_PIN:-17}"
ELBOT_POLL_INTERVAL_MS="${ELBOT_POLL_INTERVAL_MS:-1000}"

# Stop the container if it is running, and remove any stopped one with the same name.
if [ -n "$(docker ps -q -f "name=^${NAME}$")" ]; then
  echo "Container '${NAME}' is running, stopping it..."
  docker stop "${NAME}"
fi
if [ -n "$(docker ps -aq -f "name=^${NAME}$")" ]; then
  docker rm "${NAME}"
fi

echo "Pulling ${IMAGE}..."
docker pull "${IMAGE}"

echo "Starting '${NAME}' (pin=${ELBOT_GPIO_PIN}, poll=${ELBOT_POLL_INTERVAL_MS}ms)..."
docker run -d \
  --name "${NAME}" \
  --privileged \
  --restart always \
  -e ELBOT_GPIO_PIN="${ELBOT_GPIO_PIN}" \
  -e ELBOT_POLL_INTERVAL_MS="${ELBOT_POLL_INTERVAL_MS}" \
  "${IMAGE}"
