#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ANSIBLE_DIR="$ROOT_DIR/ansible"
OUTPUTS="$ANSIBLE_DIR/terraform_outputs.json"
TARGET="$ANSIBLE_DIR/group_vars/all/generated.yml"

cd "$ROOT_DIR"
terraform output -json > "$OUTPUTS"
mkdir -p "$(dirname "$TARGET")"

python3 - "$OUTPUTS" "$TARGET" <<'PY'
import json
import sys
from pathlib import Path

src, dst = sys.argv[1], sys.argv[2]
data = json.loads(Path(src).read_text())
values = {key: value.get("value") for key, value in data.items()}

lines = ["---"]
for key, value in values.items():
    if isinstance(value, list):
        lines.append(f"{key}:")
        lines.extend(f"  - {item}" for item in value)
    elif isinstance(value, bool):
        lines.append(f"{key}: {str(value).lower()}")
    elif value is None:
        lines.append(f"{key}: null")
    else:
        escaped = str(value).replace('\\', '\\\\').replace('"', '\\"')
        lines.append(f'{key}: "{escaped}"')

Path(dst).write_text("\n".join(lines) + "\n")
print(f"Updated {dst}")
PY
