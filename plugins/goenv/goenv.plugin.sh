# @chopnico 2021

# goenv exported variables
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"

# Enables goenv shims
eval "$(goenv init -)"

# Allows goenv to manage GOPATH and GOROOT
export PATH="$GOROOT/bin:$PATH"
export PATH="$PATH:$GOPATH/bin"
