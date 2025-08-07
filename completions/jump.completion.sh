#! bash oh-my-bash.module

if _omb_util_command_exists jump; then
	_jump()
	{
	    local JUMP_COMMANDS=$(jump 2>&1 | command grep -E '^ +' | awk '{print $1}')
	    COMPREPLY=( $(compgen -W "$JUMP_COMMANDS" -- "${COMP_WORDS[1]}") )
	}
	complete -F _jump jump
fi
