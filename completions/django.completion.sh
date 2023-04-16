#! bash oh-my-bash.module
# #########################################################################
# This bash script adds tab-completion feature to django-admin.py and
# manage.py.
#
# Testing it out without installing
# =================================
#
# To test out the completion without "installing" this, just run this file
# directly, like so:
#
#     . ~/path/to/django_bash_completion
#
# Note: There's a dot ('.') at the beginning of that command.
#
# After you do that, tab completion will immediately be made available in your
# current Bash shell. But it won't be available next time you log in.
#
# Installing
# ==========
#
# To install this, point to this file from your .bash_profile, like so:
#
#     . ~/path/to/django_bash_completion
#
# Do the same in your .bashrc if .bashrc doesn't invoke .bash_profile.
#
# Settings will take effect the next time you log in.
#
# Uninstalling
# ============
#
# To uninstall, just remove the line from your .bash_profile and .bashrc.

function _omb_completion_django {
  COMPREPLY=($(COMP_WORDS="${COMP_WORDS[*]}" \
    COMP_CWORD=$COMP_CWORD \
	  DJANGO_AUTO_COMPLETE=1 "$1"))
}
complete -F _omb_completion_django -o default django-admin.py manage.py django-admin

function _omb_completion_django_python {
  if ((COMP_CWORD >= 2)); then
    local PYTHON_EXE=$(basename -- "${COMP_WORDS[0]}")
    if command grep -E "python([2-9]\.[0-9])?" >/dev/null 2>&1 <<< "$PYTHON_EXE"; then
      local PYTHON_SCRIPT=$(basename -- "${COMP_WORDS[1]}")
      if command grep -E "manage\.py|django-admin(\.py)?" >/dev/null 2>&1 <<< "$PYTHON_SCRIPT"; then
        COMPREPLY=($(COMP_WORDS="${COMP_WORDS[*]:1}" \
          COMP_CWORD=$((COMP_CWORD - 1)) \
          DJANGO_AUTO_COMPLETE=1 "${COMP_WORDS[@]}"))
      fi
    fi
  fi
}

function _omb_completion_django_init {
  # Support for multiple interpreters.
  local -a pythons=()
  if _omb_util_command_exists whereis; then
    local python_interpreters
    _omb_util_split python_interpreters "$(whereis python | cut -d " " -f 2-)"
    local python
    for python in "${python_interpreters[@]}"; do
      pythons+=("$(basename -- "$python")")
    done
    _omb_util_split pythons "$(printf '%s\n' "${pythons[@]}" | sort -u)" $'\n'
  else
    pythons=(python)
  fi

  complete -F _omb_completion_django_python -o default "${pythons[@]}"
  unset -f "$FUNCNAME"
}
_omb_completion_django_init
