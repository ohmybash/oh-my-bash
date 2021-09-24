#! bash oh-my-bash.module
_omb_util_binary_exists aws_completer && complete -C "$(type -P aws_completer)" aws
