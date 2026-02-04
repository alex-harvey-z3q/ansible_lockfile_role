#!/usr/bin/env bash

set -euo pipefail

eval "$(sed -n 's/^ec2[[:space:]]*//p' inventory.ini)"  # Split the ec2 line in inventory.ini and eval each field as Bash variables.
                                                        # Sets $ansible_ssh_private_key_file, $ansible_user and $ansible_host.

lock_path="/tmp/test.lock"
owner="orphan-script"

# Default: 11 minutes old (TTL is 10 minutes = 600s), so it's clearly orphaned.
orphan_age_seconds="${1:-660}"

ssh -i "$ansible_ssh_private_key_file" -o StrictHostKeyChecking=no "$ansible_user"@"$ansible_host" sudo bash -s -- \
  "$lock_path" "$owner" "$orphan_age_seconds" <<'EOF'
set -euo pipefail

lock_path="$1"
owner="$2"
orphan_age_seconds="$3"

ts=$(( $(date +%s) - orphan_age_seconds ))
printf '%s\n%s\n' "$ts" "$owner" > "$lock_path"

echo "Created ORPHAN lock: $lock_path (ts=$ts age=${orphan_age_seconds}s owner=$owner)"
EOF
