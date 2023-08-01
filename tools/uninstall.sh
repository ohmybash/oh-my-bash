#!/bin/sh

# Note: this file is intentionally written in POSIX sh so that oh-my-bash can
# be uninstalled without bash.

_omb_uninstall_confirmation() {
  if [ "${BASH_VERSION-}" ]; then
    read -r -p "$1 " _omb_uninstall_confirmation
  else
    printf '%s ' "$1"
    read -r _omb_uninstall_confirmation
  fi
}

_omb_uninstall_contains_omb() {
  command grep -qE '(source|\.)[[:space:]]+.*[/[:space:]]oh-my-bash\.sh' "$1" 2>/dev/null
}

# Find the latest bashrc that do not source oh-my-bash.sh
_omb_uninstall_find_bashrc_original() {
  _omb_uninstall_bashrc_original=
  printf '%s\n' "Looking for original bash config..."
  _omb_uninstall_old_ifs_set=${IFS+set}
  _omb_uninstall_old_ifs=${IFS-}
  IFS='
'
  for _omb_uninstall_file in $(printf '%s\n' ~/.bashrc.omb-backup-?????????????? | sort -r) ~/.bashrc.pre-oh-my-bash; do
    [ -f "$_omb_uninstall_file" ] || [ -h "$_omb_uninstall_file" ] || continue
    _omb_uninstall_contains_omb "$_omb_uninstall_file" && continue
    _omb_uninstall_bashrc_original=$_omb_uninstall_file
    break
  done
  if [ "$_omb_uninstall_old_ifs_set" = set ]; then
    IFS=$_omb_uninstall_old_ifs
  else
    unset -v IFS
  fi
  unset -v _omb_uninstall_file _omb_uninstall_old_ifs_set _omb_uninstall_old_ifs

  if [ -n "$_omb_uninstall_bashrc_original" ]; then
    printf '%s\n' "-> Found at '$_omb_uninstall_bashrc_original'."
  else
    printf '%s\n' "-> Not found."
  fi
}

_omb_uninstall_confirmation "Are you sure you want to remove Oh My Bash? [y/N]"
if [ "$_omb_uninstall_confirmation" != y ] && [ "$_omb_uninstall_confirmation" != Y ]; then
  printf '%s\n' "Uninstall cancelled"
  unset -v _omb_uninstall_confirmation
  # shellcheck disable=SC2317
  return 0 2>/dev/null || exit 0
fi
unset -v _omb_uninstall_confirmation

if [ -d ~/.oh-my-bash ]; then
  printf '%s\n' "Removing ~/.oh-my-bash"
  command rm -rf ~/.oh-my-bash
fi

_omb_uninstall_bashrc_original=
_omb_uninstall_find_bashrc_original

if ! _omb_uninstall_contains_omb ~/.bashrc; then
  printf '%s\n' "uninstall: Oh-my-bash does not seem to be installed in .bashrc." >&2
  if [ -n "$_omb_uninstall_bashrc_original" ]; then
    printf '%s\n' "uninstall: The original config was found at '$_omb_uninstall_bashrc_original'." >&2
  fi
  printf '%s\n' "uninstall: Canceled." >&2
  unset -v _omb_uninstall_bashrc_original
  # shellcheck disable=SC2317
  return 1 2>/dev/null || exit 1
fi

_omb_uninstall_bashrc_uninstalled=
if [ -e ~/.bashrc ] || [ -h ~/.bashrc ]; then
  _omb_uninstall_bashrc_uninstalled=".bashrc.omb-uninstalled-$(date +%Y%m%d%H%M%S)";
  printf '%s\n' "Found ~/.bashrc -- Renaming to ~/${_omb_uninstall_bashrc_uninstalled}";
  command mv ~/.bashrc ~/"${_omb_uninstall_bashrc_uninstalled}";
fi

if [ -n "$_omb_uninstall_bashrc_original" ]; then
  printf '%s\n' "Found $_omb_uninstall_bashrc_original -- Restoring to ~/.bashrc";
  command mv "$_omb_uninstall_bashrc_original" ~/.bashrc;
  printf '%s\n' "Your original bash config was restored. Please restart your session."
else
  command sed '/oh-my-bash\.sh/s/^/: #/' ~/"${_omb_uninstall_bashrc_uninstalled:-.bashrc}" >| ~/.bashrc.omb-temp && \
    command mv ~/.bashrc.omb-temp ~/.bashrc
fi

unset -v _omb_uninstall_bashrc_original
unset -v _omb_uninstall_bashrc_uninstalled

echo "Thanks for trying out Oh My Bash. It has been uninstalled."
case $- in
*i*)
  # shellcheck disable=SC3044,SC3046,SC1090
  if [ -n "${BASH_VERSION-}" ]; then
    declare -f _omb_util_unload >/dev/null 2>&1 && _omb_util_unload
    source ~/.bashrc
  fi ;;
esac
