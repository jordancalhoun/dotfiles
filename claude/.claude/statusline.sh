#!/bin/bash
# Claude Code status line
# Line 1: model (effort) · dir · git branch · context % · lines changed · cost
# Line 2: 5-hour and weekly usage limit bars, with time until each resets
input=$(cat)

model=$(jq -r '.model.display_name // "Claude"' <<<"$input")
effort=$(jq -r '.effort.level // empty' <<<"$input")
dir=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
ctx=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
cost=$(jq -r '.cost.total_cost_usd // empty' <<<"$input")
added=$(jq -r '.cost.total_lines_added // 0' <<<"$input")
removed=$(jq -r '.cost.total_lines_removed // 0' <<<"$input")

dim=$'\e[2m'; reset=$'\e[0m'
cyan=$'\e[36m'; magenta=$'\e[35m'; green=$'\e[32m'; red=$'\e[31m'; yellow=$'\e[33m'
sep=" ${dim}·${reset} "

# Green under 50%, yellow from 50%, red from 80%
level_color() {
  if [ "$1" -ge 80 ]; then printf '%s' "$red"
  elif [ "$1" -ge 50 ]; then printf '%s' "$yellow"
  else printf '%s' "$green"; fi
}

# bar <percent> <width>
bar() {
  local pct=$1 width=$2 filled i out=""
  filled=$(( (pct * width + 50) / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  for ((i = 0; i < width; i++)); do
    if [ "$i" -lt "$filled" ]; then out+="█"; else out+="░"; fi
  done
  printf '%s' "$out"
}

# until <epoch seconds> -> "2h14m", "3d5h"
until_reset() {
  local secs=$(( $1 - $(date +%s) ))
  [ "$secs" -lt 0 ] && secs=0
  if [ "$secs" -ge 86400 ]; then printf '%dd%dh' $((secs / 86400)) $((secs % 86400 / 3600))
  elif [ "$secs" -ge 3600 ]; then printf '%dh%02dm' $((secs / 3600)) $((secs % 3600 / 60))
  else printf '%dm' $((secs / 60)); fi
}

out="${cyan}${model}${reset}"
[ -n "$effort" ] && out+=" ${dim}(${effort})${reset}"
out+="${sep}${dir/#$HOME/~}"

if branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null) && [ -n "$branch" ]; then
  dirty=""
  [ -n "$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null | head -1)" ] && dirty="*"
  out+="${sep}${magenta} ${branch}${dirty}${reset}"
fi

if [ -n "$ctx" ]; then
  pct=${ctx%.*}
  out+="${sep}$(level_color "$pct")ctx ${pct}%${reset}"
fi

if [ "$added" != 0 ] || [ "$removed" != 0 ]; then
  out+="${sep}${green}+${added}${reset}/${red}-${removed}${reset}"
fi

[ -n "$cost" ] && out+="${sep}$(printf '$%.2f' "$cost")"

limits=""
for window in five_hour:5h seven_day:7d; do
  key=${window%%:*} label=${window#*:}
  used=$(jq -r ".rate_limits.${key}.used_percentage // empty" <<<"$input")
  [ -z "$used" ] && continue
  resets=$(jq -r ".rate_limits.${key}.resets_at // empty" <<<"$input")
  pct=$(printf '%.0f' "$used")
  color=$(level_color "$pct")
  part="${dim}${label}${reset} ${color}$(bar "$pct" 10)${reset} ${pct}%"
  [ -n "$resets" ] && part+=" ${dim}↻ $(until_reset "$resets")${reset}"
  [ -n "$limits" ] && limits+="   "
  limits+="$part"
done

printf '%s' "$out"
[ -n "$limits" ] && printf '\n%s' "$limits"
