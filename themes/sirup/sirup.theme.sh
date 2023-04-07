#! bash oh-my-bash.module
# For unstaged(*) and staged(+) values next to branch name in __git_ps1
GIT_PS1_SHOWDIRTYSTATE="enabled"
OMB_PROMPT_VIRTUALENV_FORMAT=' [%s]'
OMB_PROMPT_CONDAENV_FORMAT=' [%s]'
OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:=false}

function _omb_theme_sirup_rubygem {
  local gemset=$(command awk -F'@' '{print $2}' <<< "$GEM_HOME")
  [[ $gemset ]] && gemset="@$gemset"

  local version=$(command awk -F'-' '{print $2}' <<< "$MY_RUBY_HOME")
  [[ $version == 1.9.2 ]] && version=

  local full=$version$gemset
  [[ $full ]] && echo "$full"
}

function _omb_theme_PROMPT_COMMAND {
  # Check http://github.com/Sirupsen/dotfiles for screenshot
  local python_venv
  _omb_prompt_get_python_venv
  PS1="$_omb_prompt_navy\W/$_omb_prompt_bold_navy$(_omb_theme_sirup_rubygem)$_omb_prompt_bold_purple$python_venv$_omb_prompt_bold_green$(__git_ps1 " (%s)") ${_omb_prompt_normal}$ "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
