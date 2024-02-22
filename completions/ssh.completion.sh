#! bash oh-my-bash.module
# Bash completion support for ssh.

_omb_module_require lib:omb-completion

function _omb_completion_ssh {
  local cur
  local additional_include_option
  local additional_include_defined_file
  _omb_completion_reassemble_breaks :

  if [[ $cur == *@*  ]] ; then
    local -a options=(-P "${cur%%@*}@" -- "${cur#*@}")
  else
    local -a options=(-- "$cur")
  fi

  # parse all defined hosts from .ssh/config
  if [[ -r $HOME/.ssh/config ]]; then
    COMPREPLY=($(compgen -W "$(grep ^Host "$HOME/.ssh/config" | awk '{for (i=2; i<=NF; i++) print $i}' )" "${options[@]}"))
  fi

  # check if .ssh/config contains Include options
  for additional_include_option in $(awk -F' ' '/^Include/{print $2}' "$HOME/.ssh/config" 2>/dev/null) ;do
    # relative or absolute path, if relative transforms to absolute
    [[ "${additional_include_option:0:1}" == "/" ]] ||additional_include_option="$HOME/.ssh/$additional_include_option"
    # for loop to interpret possible globbing
    for additional_include_defined_file in $additional_include_option ;do
      # parse all defined hosts from that file
      [[ -s "$additional_include_defined_file" ]] &&COMPREPLY+=($(compgen -W "$(grep ^Host "$additional_include_defined_file" | awk '{for (i=2; i<=NF; i++) print $i}' )" "${options[@]}"))
    done
  done

  # parse all hosts found in .ssh/known_hosts
  if [[ -r $HOME/.ssh/known_hosts ]]; then
    if grep -v -q -e '^ ssh-rsa' "$HOME/.ssh/known_hosts" ; then
      COMPREPLY+=($(compgen -W "$( awk '{print $1}' "$HOME/.ssh/known_hosts" | grep -v ^\| | cut -d, -f 1 | sed -e 's/\[//g' | sed -e 's/\]//g' | cut -d: -f1 | grep -v ssh-rsa)" "${options[@]}"))
    fi
  fi

  # parse hosts defined in /etc/hosts
  if [[ -r /etc/hosts ]]; then
    COMPREPLY+=($(compgen -W "$( grep -v '^[[:space:]]*$' /etc/hosts | grep -v '^#' | awk '{for (i=2; i<=NF; i++) print $i}' )" "${options[@]}"))
  fi

  _omb_completion_resolve_breaks
}

complete -o default -o nospace -F _omb_completion_ssh ssh scp
