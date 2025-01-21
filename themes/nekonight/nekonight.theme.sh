# nekonight Bash prompt with source control management
# Theme inspired by:
#  - Bash_it cupcake theme
# Demo:
# ╭─🐱 virtualenv 🐱user at 🐱host in 🐱directory on (🐱branch {1} ↑1 ↓1 +1 •1 ⌀1 ✗)
# ╰λ cd ~/path/to/your-directory

icon_start="╭─"
icon_user=" 🐱 \[\e[1;33m\]\u\[\e[0m\]" # Yellow-colored username
icon_host=" at 🐱 \[\e[1;36m\]\h\[\e[0m\]" # Cyan-colored hostname
icon_directory=" in 🐱 \[\e[1;35m\]\w\[\e[0m\]" # Magenta-colored current working directory
icon_branch=" on (🐱 $(git_prompt_info))" # Git branch and status information
icon_end="╰─\[\e[1m\]λ\[\e[0m\]" # Final lambda character in bold

function git_prompt_info() {
  local branch_name=$(git symbolic-ref --short HEAD 2>/dev/null)
  local git_status=""

  if [[ -n $branch_name ]]; then
    git_status="$branch_name $(scm_git_status)"
  fi

  echo -n "$git_status"
}

function scm_git_status() {
  local git_status=""

  [[ -n $(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null | grep -E '^[0-9]+\s[0-9]+$') ]] && git_status+="\[\e[33m\]↓\[\e[0m\] "

  [[ -n $(git diff --cached --name-status 2>/dev/null) ]] && git_status+="\[\e[1;32m\]+\[\e[0m\]" # Green plus

  [[ -n $(git diff --name-status 2>/dev/null) ]] && git_status+="\[\e[1;33m\]•\[\e[0m\]" # Yellow bullet

  [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]] && git_status+="⌀" # Circle for untracked files

  echo -n "$git_status"
}

export PS1="${icon_start}${icon_user}${icon_host}${icon_directory}${icon_branch}
${icon_end} "

