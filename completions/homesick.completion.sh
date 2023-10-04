#! bash oh-my-bash.module
# Bash completion script for homesick
#
# The homebrew bash completion script was used as inspiration.
# Originally from https://github.com/liborw/homesick-completion
# https://github.com/liborw/homesick-completion/blob/904d121d1b8f81629f473915a10c9144fdd416dc/homesick_bash_completion.sh

_omb_completion_homesick()
{
  local cur=${COMP_WORDS[COMP_CWORD]}
  local options="--skip --force --pretend --quiet"
  local actions="cd clone commit destroy diff generate help list open pull push rc show_path status symlink track unlink version"
  local repos=$(\ls ~/.homesick/repos)

  # Subcommand list
  if ((COMP_CWORD == 1)); then
    COMPREPLY=( $(compgen -W "${options} ${actions}" -- "$cur") )
    return
  fi

  # Find the first non-switch word
  local prev_index=1
  local prev=${COMP_WORDS[prev_index]}
  while [[ $prev == -* ]]; do
    ((++prev_index))
    prev=${COMP_WORDS[prev_index]}
  done

  # Find the number of non-"--" commands
  local num=0
  for word in "${COMP_WORDS[@]}"; do
    if [[ $word != -* ]]; then
      ((++num))
    fi
  done

  case $prev in
  # Commands that take a castle
  cd|commit|destroy|diff|open|pull|push|rc|show_path|status|symlink|unlink)
    COMPREPLY=( $(compgen -W "${repos}" -- "$cur") )
    return
    ;;
  # Commands that take command
  help)
    COMPREPLY=( $(compgen -W "${actions}" -- "$cur") )
    return
    ;;
  # Track command take file and repo
  track)
    if ((num == 2)); then
      COMPREPLY=( $(compgen -X -f "$cur") )
    elif ((num >= 3)); then
      COMPREPLY=( $(compgen -W "${repos}" -- "$cur") )
    fi
    return
    ;;
  esac
}

complete -o bashdefault -o default -F _omb_completion_homesick homesick
