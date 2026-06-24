#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$repo_root/copilot/skills"
destination_dir="${1:-$HOME/.copilot/skills}"

if [[ ! -d "$source_dir" ]]; then
  echo "Skills directory not found: $source_dir" >&2
  exit 1
fi

mkdir -p "$destination_dir"
cp -R "$source_dir"/. "$destination_dir"/

echo "Installed skills to $destination_dir"
