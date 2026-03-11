#! bash oh-my-bash.module
# Description: Aliases and utilities for npm
# Inspired by the oh-my-zsh npm plugin (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/npm)

if ! _omb_util_command_exists npm; then
  return
fi

# Install
alias npmg="npm i -g"
alias npmS="npm i -S"
alias npmD="npm i -D"
alias npmF="npm i -f"
alias npmU="npm update"

# Init / Info / Search
alias npmI="npm init"
alias npmi="npm info"
alias npmSe="npm search"

# Run scripts
alias npmst="npm start"
alias npmt="npm test"
alias npmR="npm run"
alias npmrd="npm run dev"
alias npmrb="npm run build"

# Publish
alias npmP="npm publish"

# Inspect
alias npmO="npm outdated"
alias npmV="npm -v"
alias npmL="npm list"
alias npmL0="npm ls --depth=0"

# Run a local binary from node_modules/.bin via npx
alias npmE='PATH="$(npm prefix)/node_modules/.bin:$PATH"'

# npx shortcuts
alias npmx='npx'
