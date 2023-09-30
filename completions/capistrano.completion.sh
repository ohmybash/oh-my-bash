#! bash oh-my-bash.module
# Bash completion support for Capistrano.

_omb_module_require lib:omb-completion

function _omb_completion_cap {
  local cur
  _omb_completion_reassemble_breaks :

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
    COMPREPLY=($(compgen -W '$(< .cap_tasks)' -- "$cur"))
  fi

  _omb_completion_resolve_breaks
}

complete -o default -o nospace -F _omb_completion_cap cap
