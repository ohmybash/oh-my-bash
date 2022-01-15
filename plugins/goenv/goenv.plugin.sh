#! bash oh-my-bash.module
# @chopnico 2021

if [ -d ~/.goenv ]; then
	# goenv exported variables
	export GOENV_ROOT=~/.goenv
	export PATH=$GOENV_ROOT/bin${PATH:+:$PATH}

	# Enables goenv shims
	eval -- "$(goenv init -)"

	# Allows goenv to manage GOPATH and GOROOT
	export PATH=$GOROOT/bin:$PATH
	export PATH=$PATH:$GOPATH/bin
fi
