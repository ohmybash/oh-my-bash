#! bash oh-my-bash.module
# Description: Aliases and utilities for Go development
# Inspired by the oh-my-zsh golang plugin (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/golang)

if ! _omb_util_command_exists go; then
  return
fi

_omb_module_require completion:go

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
  if [[ -z $gopath ]]; then
    _omb_util_print 'gocd: GOPATH is not set or empty' >&2
    return 1
  fi
  cd "$gopath/src/$pkg" || return $?
}
alias gocd='_omb_plugin_golang_cd'

# Run tests with a coverage report opened in the browser.
# Usage: gocov [-go-test-flags...] [packages] (defaults to ./...)
# Flags (args starting with -) are passed to go test; remaining args are
# treated as packages. If no packages are given, ./... is used as default.
function _omb_plugin_golang_cov {
  local arg flag_args=() pkg_args=()
  for arg in "$@"; do
    if [[ $arg == -* ]]; then
      flag_args+=("$arg")
    else
      pkg_args+=("$arg")
    fi
  done
  [[ ${#pkg_args[@]} -eq 0 ]] && pkg_args=(./...)

  local coverfile rc
  coverfile=$(_omb_util_mktemp) || return 1
  go test -coverprofile="$coverfile" "${flag_args[@]}" "${pkg_args[@]}" || { rm -f "$coverfile"; return $?; }
  go tool cover -html="$coverfile"
  rc=$?
  rm -f "$coverfile"
  return $rc
}
alias gocov='_omb_plugin_golang_cov'
