#! bash oh-my-bash.module

if [[ -d ~/.rbenv ]]; then
  export RBENV_ROOT=~/.rbenv
	export PATH=$RBENV_ROOT/bin:$PATH
  eval "$(rbenv init - bash)"

  alias rubies='rbenv versions'
fi
