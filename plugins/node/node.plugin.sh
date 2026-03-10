#! bash oh-my-bash.module
# Description: Aliases and utilities for Node.js development
# Inspired by the oh-my-zsh node plugin (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/node)

if ! _omb_util_command_exists node; then
  return
fi

alias node-version='node --version'

#------------------------------------------------------------------------------
# Open the Node.js API documentation for the current version in a browser.
# Usage: node-docs [section]
# Examples:
#   node-docs           # opens the full API index
#   node-docs fs        # opens the 'fs' module page
#   node-docs http      # opens the 'http' module page
function node-docs {
  local section=${1:-all}
  local version
  version=$(node --version)
  local url="https://nodejs.org/docs/${version}/api/${section}.html"

  if _omb_util_command_exists xdg-open; then
    xdg-open "$url"
  elif _omb_util_command_exists open; then
    open "$url"
  else
    _omb_util_print "$url"
  fi
}

#------------------------------------------------------------------------------
# Print a Node.js-friendly JSON representation of an object via node -e.
# Usage: node-json <expression>
# Example: node-json 'process.versions'
function node-json {
  if [[ -z ${1-} ]]; then
    _omb_util_print 'node-json: usage: node-json <expression>' >&2
    return 1
  fi
  node -e "console.log(JSON.stringify($1, null, 2))"
}
