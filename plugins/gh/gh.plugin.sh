#!/bin/bash oh-my-bash.module
# gh.plugin.bash - Aliases and functions for GitHub CLI
# Author: Jose2004 (github.com/jose2004)


# -------------------------------------------------------------------------------------------#
# This plugin provides convenient aliases and functions for using the GitHub CLI (gh) tool.
# -------------------------------------------------------------------------------------------#


if ! _omb_util_command_exists gh; then
  _omb_util_print "[oh-my-bash] GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/" >&2
fi

# Functions

function gh-info() {
  gh --version
  echo "---"
  gh auth status
}

# Create a pull request with title and optional body
function gh-pr-create() {
  if [[ -z "$1" ]]; then
    _omb_util_print "Usage: gh-pr-create <title> [body]"
    _omb_util_print "Example: gh-pr-create \"Fix navbar bug\" \"This PR fixes the responsive navbar issue\""
    return 1
  fi
  local title="$1"
  local body="${2:-}"
  gh pr create --title "$title" --body "$body" --web
}

# List issues with optional state filter (open/closed)
function gh-issue-list() {
  local state="${1:-open}"
  gh issue list --state "$state"
}

# Clone a repository (username/repo format)
function gh-repo-clone() {
  if [[ -z "$1" ]]; then
    _omb_util_print "Usage: gh-repo-clone <repository>"
    _omb_util_print "Example: gh-repo-clone octocat/Hello-World"
    return 1
  fi
  gh repo clone "$1"
}

# View and filter pull requests
function gh-pr-list() {
  local state="${1:-open}"
  gh pr list --state "$state"
}

# --------------------------------------------------------------------------------
# Aliases

# Core
alias ghrv='gh repo view'                    # View repository
alias ghrvw='gh repo view --web'              # View repository in browser
alias ghrc='gh-repo-clone'                     # Clone repository (uses function)
alias ghrl='gh repo list'                      # List repositories

alias ghrel='gh release'                       # Releases base command
alias ghrell='gh release list'                  # List releases
alias ghrelc='gh release create'                # Create release
alias ghrelv='gh release view'                  # View release

alias ghpr='gh-pr-list'                         # List PRs (open by default)
alias ghpro='gh pr list --state open'           # List open PRs
alias ghprc='gh-pr-create'                       # Create PR (uses function)
alias ghprco='gh pr checkout'                    # Checkout PR
alias ghprs='gh pr status'                       # PR status
alias ghprch='gh pr checks'                      # View PR checks
alias ghprv='gh pr view'                         # View PR
alias ghprvw='gh pr view --web'                   # View PR in browser

alias ghis='gh-issue-list'                        # List issues (open by default)
alias ghio='gh issue list --state open'           # List open issues
alias ghic='gh issue list --state closed'         # List closed issues
alias ghisc='gh issue create'                     # Create issue
alias ghisv='gh issue view'                       # View issue
alias ghisvw='gh issue view --web'                 # View issue in browser

alias ghg='gh gist'                                # Gists base command
alias ghgl='gh gist list'                          # List gists
alias ghgc='gh gist create'                        # Create gist

alias ghw='gh workflow'                            # Workflows base command
alias ghwl='gh workflow list'                      # List workflows
alias ghwr='gh workflow run'                       # Run workflow
alias ghwv='gh workflow view'                       # View workflow

alias gha='gh api'                                 # Call GitHub API
alias ghal='gh alias list'                         # List aliases

alias ghst='gh status'                             # Repository status
alias ghauth='gh auth status'                       # Authentication status
alias ghver='gh-info'                               # Version and auth info (uses function)
