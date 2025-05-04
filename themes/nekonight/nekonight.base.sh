#! bash oh-my-bash.module

icon_start="╭─"
icon_user=" ${_omb_theme_nekonight_icon_emoji} ${_omb_prompt_bold_olive}\u${_omb_prompt_normal}"
icon_host=" at ${_omb_theme_nekonight_icon_emoji} ${_omb_prompt_bold_cyan}\h${_omb_prompt_normal}"
icon_directory=" in ${_omb_theme_nekonight_icon_emoji} ${_omb_prompt_bold_magenta}\w${_omb_prompt_normal}"
icon_end="╰─${_omb_prompt_bold_white}λ${_omb_prompt_normal}"

function _omb_theme_nekonight_git_prompt_info() {
  local branch_name
  branch_name=$(_omb_prompt_git symbolic-ref --short HEAD 2>&-)
  local git_status=""

  local icon_emoji="${_omb_theme_nekonight_icon_emoji:-🐱}"

  if [[ -n $branch_name ]]; then
    git_status="${_omb_prompt_bold_white} (${icon_emoji} $branch_name $(_omb_theme_nekonight_scm_git_status))${_omb_prompt_normal}"
  fi

  echo -n "$git_status"
}

function _omb_theme_nekonight_scm_git_status() {
  local git_status=""

  if _omb_prompt_git rev-list --count --left-right @{upstream}...HEAD 2>&- | grep -Eq '^[0-9]+[[:blank:]][0-9]+$'; then
    git_status+="${_omb_prompt_brown}↓${_omb_prompt_normal} "
  fi

  if [[ -n $(_omb_prompt_git diff --cached --name-status 2>&-) ]]; then
    git_status+="${_omb_prompt_green}+${_omb_prompt_normal}"
  fi

  if [[ -n $(_omb_prompt_git diff --name-status 2>&-) ]]; then
    git_status+="${_omb_prompt_yellow}•${_omb_prompt_normal}"
  fi

  if [[ -n $(_omb_prompt_git ls-files --others --exclude-standard 2>&-) ]]; then
    git_status+="${_omb_prompt_red}⌀${_omb_prompt_normal}"
  fi

  echo -n "$git_status"
}
