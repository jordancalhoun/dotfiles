#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0")

Find backup files created while stowing dotfiles and offer to delete them.
Nothing is deleted without an explicit confirmation.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  *)
    printf 'Error: unexpected argument: %s\n' "$1" >&2
    usage >&2
    exit 1
    ;;
  esac
done

declare -a backups=()
backup=""
backup_name=""

# setup.sh creates names ending in .stow-bak-YYYYMMDD-HHMMSS, with an
# optional numeric suffix when more than one backup is made in the same second.
while IFS= read -r -d '' backup; do
  backup_name="${backup##*/}"
  if [[ "$backup_name" =~ \.stow-bak-[0-9]{8}-[0-9]{6}(-[0-9]+)?$ ]]; then
    backups+=("$backup")
  fi
done < <(find "$HOME" -depth -name '*.stow-bak-*' -print0)

if [[ ${#backups[@]} -eq 0 ]]; then
  printf '%s\n' "No Stow conflict backups found under $HOME."
  exit 0
fi

printf 'Found %d Stow conflict backup(s):\n' "${#backups[@]}"
printf '  %s\n' "${backups[@]}"
printf '\nDelete all of these backups? [y/N]: '

answer=""
IFS= read -r answer
case "$answer" in
y | Y | yes | YES | Yes)
  for backup in "${backups[@]}"; do
    rm -rf -- "$backup"
  done
  printf 'Deleted %d Stow conflict backup(s).\n' "${#backups[@]}"
  ;;
*)
  printf '%s\n' "Nothing deleted."
  ;;
esac
