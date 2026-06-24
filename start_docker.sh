#!/bin/bash
set -e

cd /home/tpcoleary/agenticSeek
export SEARXNG_SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(32))')
echo "Launching agenticSeek containers in detached mode..."
docker compose --profile full up -d
echo "All containers started successfully!"
