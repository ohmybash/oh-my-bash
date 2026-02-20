#! bash oh-my-bash.module

function _omb_completion_ansible {
  local -A commands=(
    [a]='ansible'
    [aconf]='ansible-config'
    [acon]='ansible-console'
    [adoc]='ansible-doc'
    [agal]='ansible-galaxy'
    [ainv]='ansible-inventory'
    [aplay]='ansible-playbook'
    [aplaybook]='ansible-playbook'
    [apull]='ansible-pull'
    [atest]='ansible-test'
    [aval]='ansible-vault'
  )
  _python_argcomplete_global "${commands[$1]}" -- "${COMP_WORDS[@]:1}"
}
complete -F _omb_completion_ansible a
complete -F _omb_completion_ansible aconf
complete -F _omb_completion_ansible acon
complete -F _omb_completion_ansible adoc
complete -F _omb_completion_ansible agal
complete -F _omb_completion_ansible ainv
complete -F _omb_completion_ansible aplay
complete -F _omb_completion_ansible aplaybook
complete -F _omb_completion_ansible apull
complete -F _omb_completion_ansible atest
complete -F _omb_completion_ansible aval
