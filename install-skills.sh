#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$repo_root/copilot/skills"
default_destination="$HOME/.copilot/skills"
destination_dir="$default_destination"
install_mode=""
selected_skills_raw=""

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

list_skills() {
  find "$source_dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

array_contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

usage() {
  cat <<'EOF'
Usage:
  ./install-skills.sh [destination]
  ./install-skills.sh [destination] --all
  ./install-skills.sh [destination] --skills skill1,skill2
  ./install-skills.sh --destination /path --all
  ./install-skills.sh --destination /path --skills skill1,skill2

Options:
  --all, -a                 Install all available skills
  --skills, -s <csv>        Install only selected skills (comma-separated)
  --destination, -d <path>  Installation path (default: ~/.copilot/skills)
  --list, -l                List available skills and exit
  --help, -h                Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all|-a)
      install_mode="all"
      shift
      ;;
    --skills|-s)
      install_mode="selected"
      selected_skills_raw="${2:-}"
      if [[ -z "$selected_skills_raw" ]]; then
        echo "Missing value for --skills." >&2
        exit 1
      fi
      shift 2
      ;;
    --destination|-d)
      destination_dir="${2:-}"
      if [[ -z "$destination_dir" ]]; then
        echo "Missing value for --destination." >&2
        exit 1
      fi
      shift 2
      ;;
    --list|-l)
      list_skills
      exit 0
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ "$destination_dir" == "$default_destination" ]]; then
        destination_dir="$1"
      else
        echo "Unexpected positional argument: $1" >&2
        usage >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ ! -d "$source_dir" ]]; then
  echo "Skills directory not found: $source_dir" >&2
  exit 1
fi

available_skills=()
while IFS= read -r skill; do
  available_skills+=("$skill")
done < <(list_skills)

if [[ ${#available_skills[@]} -eq 0 ]]; then
  echo "No skills found in $source_dir" >&2
  exit 1
fi

if [[ -z "$install_mode" ]]; then
  echo "Choose install mode:"
  echo "1) Install all skills"
  echo "2) Select specific skills"
  read -r -p "Enter 1 or 2: " choice

  case "$choice" in
    1)
      install_mode="all"
      ;;
    2)
      install_mode="selected"
      echo "Available skills:"
      printf ' - %s\n' "${available_skills[@]}"
      read -r -p "Enter comma-separated skill names: " selected_skills_raw
      ;;
    *)
      echo "Invalid choice: $choice" >&2
      exit 1
      ;;
  esac
fi

declare -a skills_to_install=()
if [[ "$install_mode" == "all" ]]; then
  skills_to_install=("${available_skills[@]}")
else
  IFS=',' read -r -a requested_skills <<< "$selected_skills_raw"
  if [[ ${#requested_skills[@]} -eq 0 ]]; then
    echo "No skills provided." >&2
    exit 1
  fi

  for raw_skill in "${requested_skills[@]}"; do
    skill="$(trim "$raw_skill")"
    if [[ -z "$skill" ]]; then
      continue
    fi
    if ! array_contains "$skill" "${available_skills[@]}"; then
      echo "Unknown skill: $skill" >&2
      echo "Available skills: ${available_skills[*]}" >&2
      exit 1
    fi
    if ! array_contains "$skill" "${skills_to_install[@]-}"; then
      skills_to_install+=("$skill")
    fi
  done

  if [[ ${#skills_to_install[@]} -eq 0 ]]; then
    echo "No valid skills selected." >&2
    exit 1
  fi
fi

mkdir -p "$destination_dir"
for skill in "${skills_to_install[@]}"; do
  mkdir -p "$destination_dir/$skill"
  cp -R "$source_dir/$skill"/. "$destination_dir/$skill"/
done

echo "Installed skills to $destination_dir:"
printf ' - %s\n' "${skills_to_install[@]}"
