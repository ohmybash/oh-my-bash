#! bash oh-my-bash.module
# Description: Aliases and utilities for Python development
# Inspired by the oh-my-zsh python plugin (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/python)
#
# @var[opt] OMB_PLUGIN_PYTHON_VENV_NAME  default venv directory name (default: venv)
# @var[opt] OMB_PLUGIN_PYTHON_AUTO_VRUN  set to 'true' to auto-activate venv on directory change

# Use 'py' as a shorthand for python3 if not already defined
_omb_util_command_exists py || alias py='python3'

# Find Python source files
alias pyfind='find . -name "*.py"'

# Grep within Python source files
alias pygrep='grep -rn --include="*.py"'

# Serve the current directory over HTTP
alias pyserver='python3 -m http.server'

# Remove compiled bytecode and cache directories left by Python tools
function pyclean {
  find "${@:-.}" -type f -name "*.py[co]" -delete
  find "${@:-.}" -type d -name "__pycache__" -delete
  find "${@:-.}" -depth -type d -name ".mypy_cache" -exec rm -r "{}" +
  find "${@:-.}" -depth -type d -name ".pytest_cache" -exec rm -r "{}" +
}

#------------------------------------------------------------------------------
# pip aliases

alias pipi='pip install'
alias pipu='pip uninstall'
alias pipup='pip install --upgrade'
alias pipr='pip install -r requirements.txt'
alias pipf='pip freeze'
alias pipfr='pip freeze > requirements.txt'
alias pipls='pip list'
alias pipout='pip list --outdated'

#------------------------------------------------------------------------------
# Virtual environment management
#
# @var[opt] OMB_PLUGIN_PYTHON_VENV_NAME  default venv name used by vrun/mkv (default: venv)

: "${OMB_PLUGIN_PYTHON_VENV_NAME:=venv}"

# Build the ordered, deduplicated list of venv names to search
_omb_plugin_python_venv_names=("$OMB_PLUGIN_PYTHON_VENV_NAME")
for _omb_plugin_python__n in venv .venv; do
  [[ " ${_omb_plugin_python_venv_names[*]} " == *" $_omb_plugin_python__n "* ]] ||
    _omb_plugin_python_venv_names+=("$_omb_plugin_python__n")
done
unset -v _omb_plugin_python__n

# Activate a virtual environment.
# Usage: vrun [name]
# If no name is given, searches for the first matching directory in
# $OMB_PLUGIN_PYTHON_VENV_NAME, venv, .venv (in that order).
function vrun {
  if [[ -z ${1-} ]]; then
    local name
    for name in "${_omb_plugin_python_venv_names[@]}"; do
      if [[ -d $name ]]; then
        vrun "$name"
        return $?
      fi
    done
    _omb_util_print 'vrun: no virtual environment found in current directory' >&2
    return 1
  fi

  local name=$1
  if [[ ! -d $name ]]; then
    _omb_util_print "vrun: no such venv in current directory: $name" >&2
    return 1
  fi
  if [[ ! -f $name/bin/activate ]]; then
    _omb_util_print "vrun: '$name' is not a proper virtual environment" >&2
    return 1
  fi

  # shellcheck source=/dev/null
  . "$name/bin/activate" || return $?
  _omb_util_print "Activated virtual environment $name"
}

# Create a new virtual environment and immediately activate it.
# Usage: mkv [name]
# Defaults to $OMB_PLUGIN_PYTHON_VENV_NAME if no name is given.
function mkv {
  local name=${1:-$OMB_PLUGIN_PYTHON_VENV_NAME}
  python3 -m venv "$name" || return $?
  _omb_util_print "Created venv in '$PWD/$name'"
  vrun "$name"
}

#------------------------------------------------------------------------------
# Auto-activate venv on directory change
#
# When OMB_PLUGIN_PYTHON_AUTO_VRUN=true, automatically activates a venv when
# entering a directory that contains one, and deactivates it when leaving.

if [[ ${OMB_PLUGIN_PYTHON_AUTO_VRUN-} == true ]]; then
  function _omb_plugin_python_auto_vrun {
    # Deactivate if we have left the project directory that owns the current venv
    if [[ $(type -t deactivate) == function ]] && [[ -n ${VIRTUAL_ENV-} ]] &&
       [[ $PWD != "${VIRTUAL_ENV%/*}"* ]]; then
      deactivate > /dev/null 2>&1
    fi

    # Skip if this directory is already the active venv's home
    [[ -n ${VIRTUAL_ENV-} && $PWD == "${VIRTUAL_ENV%/*}" ]] && return 0

    local name
    for name in "${_omb_plugin_python_venv_names[@]}"; do
      if [[ -f $name/bin/activate ]]; then
        [[ $(type -t deactivate) == function ]] && deactivate > /dev/null 2>&1
        # shellcheck source=/dev/null
        source "$name/bin/activate" > /dev/null 2>&1
        break
      fi
    done
  }

  function _omb_plugin_python_cd {
    command cd "$@" || return $?
    _omb_plugin_python_auto_vrun
  }
  alias cd='_omb_plugin_python_cd'

  # Run once for the shell's starting directory
  _omb_plugin_python_auto_vrun
fi
