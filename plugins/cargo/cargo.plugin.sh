#! bash oh-my-bash.module
# @sjplanet 2025

if [ -d ~/.cargo ]; then
	# cargo exported variables
	export CARGO_HOME=~/.cargo
	export PATH=$CARGO_HOME/bin${PATH:+:$PATH}

fi
