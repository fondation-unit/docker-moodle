#!/usr/bin/env bash

set -euo pipefail

echo "Stopping stack..."
sudo docker compose down

echo "Removing Moodle container..."
sudo docker compose rm -f moodle

echo "Removing moodle_src volume..."
sudo docker volume rm docker-moodle_moodle_src

echo "Rebuilding Moodle image..."
sudo docker compose build --no-cache moodle

echo "Upgrade Moodle..."
sudo docker compose up -d moodle
sudo docker compose exec moodle php admin/cli/upgrade.php
sudo docker compose exec moodle php admin/cli/purge_caches.php
sudo docker compose rm -f moodle

echo "✔︎ Update completed."
