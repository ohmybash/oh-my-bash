#!/usr/bin/env bash

# Note: this file is intentionally written in POSIX sh so that oh-my-bash can
# be uninstalled without bash.

_omb_uninstall_contains_omb() {
  command grep -qE '(source|\.)[[:space:]]+.*[/[:space:]]oh-my-bash\.sh' "$1" 2>/dev/null
}

# Find the latest bashrc that do not source oh-my-bash.sh
_omb_uninstall_find_bashrc_original() {
  _omb_uninstall_bashrc_original=
  printf '%s\n' "Looking for original bash config..."
  IFS='
'
  for _omb_uninstall_file in $(printf '%s\n' ~/.bashrc.omb-backup-?????????????? | sort -r) ~/.bashrc.pre-oh-my-bash; do
    [ -f "$_omb_uninstall_file" ] || [ -h "$_omb_uninstall_file" ] || continue
    _omb_uninstall_contains_omb "$_omb_uninstall_file" && continue
    _omb_uninstall_bashrc_original=$_omb_uninstall_file
    break
  done
  unset _omb_uninstall_file
  IFS=' 	
'
  if [ -n "$_omb_uninstall_bashrc_original" ]; then
    printf '%s\n' "-> Found at '$_omb_uninstall_bashrc_original'."
  else
    printf '%s\n' "-> Not found."
  fi
}

read -r -p "Are you sure you want to remove Oh My Bash? [y/N] " _omb_uninstall_confirmation
if [ "$_omb_uninstall_confirmation" != y ] && [ "$_omb_uninstall_confirmation" != Y ]; then
  printf '%s\n' "Uninstall cancelled"
  unset _omb_uninstall_confirmation
  return 0 2>/dev/null || exit 0
fi
unset _omb_uninstall_confirmation

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
  unset _omb_uninstall_bashrc_original
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

unset _omb_uninstall_bashrc_original
unset _omb_uninstall_bashrc_uninstalled

echo "Thanks for trying out Oh My Bash. It has been uninstalled."
case $- in
*i*)
  if [ -n "${BASH_VERSION-}" ]; then
    declare -f _omb_util_unload >/dev/null 2>&1 && _omb_util_unload
    source ~/.bashrc
  fi ;;
esac
