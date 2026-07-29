#!/usr/bin/env bash

SHARED_REPOSITORIES=(
  "codecarton/codecarton.com-v2"
  "codecarton/Devote"
  "codecarton/One16"
  "codecarton/Ditches"
  "codecarton/swiftpkg"
)

AGENT_REPOSITORIES=(
  # "OWNER/AGENT_ONLY_REPO"
)

USER_REPOSITORIES=(
  # "OWNER/USER_ONLY_REPO"
)

offer_to_clone_repositories() {
  local user_type="$1"
  local clone_root="$HOME/Projects"
  local -a repositories=()
  local -a role_repositories=()
  local repository=""
  local repository_name=""
  local destination=""

  case "$user_type" in
  agent) role_repositories=("${AGENT_REPOSITORIES[@]-}") ;;
  user) role_repositories=("${USER_REPOSITORIES[@]-}") ;;
  *)
    err "Cannot select repositories for unknown user type: $user_type"
    return 1
    ;;
  esac

  for repository in "${SHARED_REPOSITORIES[@]-}" "${role_repositories[@]}"; do
    [[ -n "$repository" ]] && repositories+=("$repository")
  done

  if [[ ${#repositories[@]} -eq 0 ]]; then
    log "No GitHub repositories configured for user type: $user_type"
    return 0
  fi

  printf '%s\n' \
    "GitHub repositories configured for $user_type:" \
    "$(printf '  %s\n' "${repositories[@]}")" \
    "Clone destination: $clone_root"

  if ! ask_yes_no "Clone these GitHub repositories?"; then
    log "Skipping GitHub repository cloning"
    return 0
  fi

  ensure_dir "$clone_root"
  for repository in "${repositories[@]}"; do
    if [[ ! "$repository" =~ ^[^/[:space:]]+/[^/[:space:]]+$ ]]; then
      warn "Expected OWNER/REPO; skipping: $repository"
      continue
    fi

    repository_name="${repository##*/}"
    repository_name="${repository_name%.git}"
    destination="$clone_root/$repository_name"

    if [[ -e "$destination" || -L "$destination" ]]; then
      warn "Skipping '$repository': destination already exists at $destination"
      continue
    fi

    log "Cloning $repository -> $destination"
    if ! gh repo clone "$repository" "$destination"; then
      warn "Failed to clone '$repository'; continuing"
    fi
  done
}
