#! bash oh-my-bash.module
# Description: Aliases and utilities for Go development
# Inspired by the oh-my-zsh golang plugin (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/golang)

_omb_module_require completion:go

if ! _omb_util_command_exists go; then
  return
fi

# Build
alias gob='go build'
alias goba='go build ./...'

# Clean
alias goc='go clean'

# Doc
alias god='go doc'

# Env
alias goe='go env'

# Fix
alias gofx='go fix'

# Format
alias gof='go fmt'
alias gofa='go fmt ./...'

# Get
alias gog='go get'
alias goga='go get ./...'

# Install
alias goi='go install'

# List
alias gol='go list'

# Mod
alias gom='go mod'
alias gomt='go mod tidy'
alias gomi='go mod init'
alias gomv='go mod vendor'

# Run
alias gor='go run'

# Test
alias got='go test'
alias gota='go test ./...'
alias gotv='go test -v'
alias gotva='go test -v ./...'

# Tool
alias goto='go tool'
alias gotoc='go tool compile'
alias gotod='go tool dist'
alias gotofx='go tool fix'

# Vet
alias gov='go vet'
alias gova='go vet ./...'

# Version
alias gove='go version'

# Work
alias gow='go work'

# Navigate to $GOPATH
alias gop='cd $GOPATH'
alias gopb='cd $GOPATH/bin'
alias gops='cd $GOPATH/src'

#------------------------------------------------------------------------------
# Utility functions

# Navigate to a package's source directory under $GOPATH/src.
# Usage: gocd <package>
function _omb_plugin_golang_cd {
  local pkg=$1
  if [[ -z $pkg ]]; then
    _omb_util_print 'gocd: usage: gocd <package>' >&2
    return 1
  fi
  local gopath
  gopath=$(go env GOPATH)
  cd "$gopath/src/$pkg" || return $?
}
alias gocd='_omb_plugin_golang_cd'

# Run tests with a coverage report opened in the browser.
# Usage: gocov [go test flags] (defaults to ./...)
function _omb_plugin_golang_cov {
  local coverfile
  coverfile=$(mktemp /tmp/go-cover-XXXXXX.out)
  go test -coverprofile="$coverfile" "${@:-./...}" || { rm -f "$coverfile"; return $?; }
  go tool cover -html="$coverfile"
  rm -f "$coverfile"
}
alias gocov='_omb_plugin_golang_cov'
