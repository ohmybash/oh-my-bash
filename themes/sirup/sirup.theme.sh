# For unstaged(*) and staged(+) values next to branch name in __git_ps1
GIT_PS1_SHOWDIRTYSTATE="enabled"

function _omb_theme_sirup_rubygem {
  local gemset=$(command awk -F'@' '{print $2}' <<< "$GEM_HOME")
  [[ $gemset ]] && gemset="@$gemset"

  local version=$(command awk -F'-' '{print $2}' <<< "$MY_RUBY_HOME")
  [[ $version == 1.9.2 ]] && version=

  local full=$version$gemset
  [[ $full ]] && echo "$full"
}
 
function prompt_command {
  # Check http://github.com/Sirupsen/dotfiles for screenshot
  PS1="$blue\W/$bold_blue$(_omb_theme_sirup_rubygem)$bold_green$(__git_ps1 " (%s)") ${normal}$ "
}

_omb_util_add_prompt_command prompt_command
