#! bash oh-my-bash.module
# Upstream: https://github.com/django/django/blob/90c59b4e12e6ff41407694a460f5f30c4688dbfd/extras/django_bash_completion
#
# #########################################################################
# This bash script adds tab-completion feature to django-admin and manage.py.
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
# When the django-admin.py deprecation ends, remove django-admin.py.
complete -F _omb_completion_django -o default manage.py django-admin

function _omb_completion_django_python {
  if ((COMP_CWORD >= 2)); then
    if command grep -qE "python([3-9]\.[0-9])?" <<< "${COMP_WORDS[0]##*/}"; then
      if command grep -qE "manage\.py|django-admin" <<< "${COMP_WORDS[1]##*/}"; then
        COMPREPLY=($(COMP_WORDS="${COMP_WORDS[*]:1}" \
          COMP_CWORD=$((COMP_CWORD - 1)) \
          DJANGO_AUTO_COMPLETE=1 "${COMP_WORDS[@]}"))
      fi
    fi
  fi
}

function _omb_completion_django_init {
  # Support for multiple interpreters.
  local -a pythons=(python)
  if _omb_util_command_exists whereis; then
    local python_interpreters
    _omb_util_split python_interpreters "$(whereis python | cut -d " " -f 2-)"
    local python
    for python in "${python_interpreters[@]}"; do
      [[ -x $python ]] || continue
      [[ $python == *-config ]] || continue
      python=${python##*/}
      [[ $python ]] && pythons+=("$python")
    done
    _omb_util_split pythons "$(printf '%s\n' "${pythons[@]}" | sort -u)" $'\n'
  fi

  complete -F _omb_completion_django_python -o default "${pythons[@]}"
  unset -f "$FUNCNAME"
}
_omb_completion_django_init
