#! bash oh-my-bash.module
# Bash completion support for Rake, Ruby Make.

_omb_module_require lib:omb-completion

function _omb_completion_rake {
  local cur
  _omb_completion_reassemble_breaks :

  if [[ -f Rakefile ]]; then
    local recent=$(ls -t .rake_tasks~ Rakefile **/*.rake 2> /dev/null | head -n 1)
    if [[ $recent != '.rake_tasks~' ]]; then
      rake --silent --tasks --all | cut -d " " -f 2 > .rake_tasks~
    fi
    COMPREPLY=($(compgen -W '$(< .rake_tasks~)' -- "$cur"))
  fi

  _omb_completion_resolve_breaks
}

complete -o default -o nospace -F _omb_completion_rake rake
