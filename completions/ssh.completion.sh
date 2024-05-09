#! bash oh-my-bash.module
# Bash completion support for ssh.

_omb_module_require lib:omb-completion

function _omb_completion_ssh {
  local cur
  _omb_completion_reassemble_breaks :

  local -a options
  if [[ $cur == *@*  ]] ; then
    options=(-P "${cur%%@*}@" -- "${cur#*@}")
  else
    options=(-- "$cur")
  fi

  local IFS=$'\n'

  # parse all defined hosts from .ssh/config
  if [[ -r ~/.ssh/config ]]; then
    local -a config_files=(~/.ssh/config)

    # check if .ssh/config contains Include options
    local -a include_patterns
    _omb_util_split include_patterns "$(awk -F' ' '/^Include/{print $2}' ~/.ssh/config 2>/dev/null)" $'\n'
    local i
    for i in "${!include_patterns[@]}"; do
      # relative or absolute path, if relative transforms to absolute
      [[ ${include_patterns[i]} == /* ]] || include_patterns[i]=~/.ssh/${include_patterns[i]}
    done

    # interpret possible globbing
    local -a include_files
    _omb_util_glob_expand include_files '${include_patterns[*]}'
    local include_file
    for include_file in "${include_files[@]}";do
      # parse all defined hosts from that file
      [[ -s $include_file ]] && config_files+=("$include_file")
    done

    COMPREPLY+=($(compgen -W "$(awk '/^Host/ {for (i=2; i<=NF; i++) print $i}' "${config_files[@]}")" "${options[@]}"))
  fi

  # parse all hosts found in .ssh/known_hosts
  if [[ -r ~/.ssh/known_hosts ]]; then
    if grep -v -q -e '^ ssh-rsa' ~/.ssh/known_hosts; then
      COMPREPLY+=($(compgen -W "$( awk '{print $1}' ~/.ssh/known_hosts | grep -v ^\| | cut -d, -f 1 | sed -e 's/\[//g' | sed -e 's/\]//g' | cut -d: -f1 | grep -v ssh-rsa)" "${options[@]}"))
    fi
  fi

  # parse hosts defined in /etc/hosts
  if [[ -r /etc/hosts ]]; then
    COMPREPLY+=($(compgen -W "$( grep -v '^[[:space:]]*$' /etc/hosts | grep -v '^#' | awk '{for (i=2; i<=NF; i++) print $i}' )" "${options[@]}"))
  fi

  _omb_completion_resolve_breaks
}

complete -o default -o nospace -F _omb_completion_ssh ssh scp
