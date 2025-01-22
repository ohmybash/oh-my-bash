# Função para obter informações do Git (branch e status)
function _omb_theme_nekonight_git_prompt_info() {
  local branch_name
  branch_name=$(git symbolic-ref --short HEAD 2>&-)
  local git_status=""

  if [[ -n $branch_name ]]; then
    git_status="${_omb_prompt_bold_white}(🐱 $branch_name $(_omb_theme_nekonight_scm_git_status))${_omb_prompt_normal}"
  fi

  echo -n "$git_status"
}

# Função para obter o status do Git
function _omb_theme_nekonight_scm_git_status() {
  local git_status=""

  # Alterações em comparação ao branch upstream
  if git rev-list --count --left-right @{upstream}...HEAD 2>&- | grep -Eq '^[0-9]+\s[0-9]+$'; then
    git_status+="${_omb_prompt_brown}↓${_omb_prompt_normal} "
  fi

  # Alterações staged
  if [[ -n $(git diff --cached --name-status 2>&-) ]]; then
    git_status+="${_omb_prompt_green}+${_omb_prompt_normal}"
  fi

  # Alterações unstaged
  if [[ -n $(git diff --name-status 2>&-) ]]; then
    git_status+="${_omb_prompt_yellow}•${_omb_prompt_normal}"
  fi

  # Arquivos não rastreados
  if [[ -n $(git ls-files --others --exclude-standard 2>&-) ]]; then
    git_status+="${_omb_prompt_red}⌀${_omb_prompt_normal}"
  fi

  echo -n "$git_status"
}

