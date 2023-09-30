#! bash oh-my-bash.module
# Bash completion support for Capistrano.

export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

function _omb_completion_cap {
  if [[ -f Capfile ]]; then
    local recent=$(ls -t .cap_tasks~ Capfile **/*.cap 2> /dev/null | head -n 1)
    if [[ $recent != '.cap_tasks~' ]]; then
      if cap --version | grep 'Capistrano v2.' > /dev/null; then
        # Capistrano 2.x
        cap --tool --verbose --tasks | cut -d " " -f 2 > .cap_tasks~
      else
        # Capistrano 3.x
        cap --all --tasks | cut -d " " -f 2 > .cap_tasks~
      fi
    fi
    COMPREPLY=($(compgen -W '$(< .cap_tasks)' -- "${COMP_WORDS[COMP_CWORD]}"))
    return 0
  fi
}

complete -o default -o nospace -F _omb_completion_cap cap
