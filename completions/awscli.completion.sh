#! bash oh-my-bash.module
[[ -x "$(which aws_completer)" ]] &>/dev/null && complete -C "$(which aws_completer)" aws
