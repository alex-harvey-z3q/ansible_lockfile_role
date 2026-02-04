#!/usr/bin/env bash

set -euo pipefail

host="3.106.213.242"
key="$HOME"/.ssh/default.pem
lock_path="/tmp/test.lock"
owner="shell-script"

hold_seconds="${1:-}"

if [[ -z "$hold_seconds" ]]; then
  echo "Usage: $0 HOLD_SECONDS"
  exit 1
fi

ssh -i "$key" -o StrictHostKeyChecking=no "ec2-user@$host" sudo bash -s -- \
  "$lock_path" "$owner" "$hold_seconds" <<'EOF'
set -euo pipefail

lock_path="$1"
owner="$2"
hold_seconds="$3"

now="$(date +%s)"
printf '%s\n%s\n' "$now" "$owner" > "$lock_path"

echo "Created lock: $lock_path (ts=$now owner=$owner)"
echo "Holding for ${hold_seconds}s..."
sleep "$hold_seconds"

rm -f "$lock_path"
echo "Released lock: $lock_path"
EOF
