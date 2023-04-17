#! bash oh-my-bash.module
# @chopnico 2021

if [ -d ~/.pyenv ]; then
	export PYENV_ROOT=~/.pyenv
	export PATH=$PYENV_ROOT/bin${PATH:+:$PATH}
	eval -- "$(pyenv init --path)"
	eval -- "$(pyenv init -)"
fi
