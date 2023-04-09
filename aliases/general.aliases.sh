#! bash oh-my-bash.module
#------------------------------------------------------------------------------
# Note on copyright (2022-08-23): The aliases defined in this file seems to
# originally come from a blog post [1].  See also the comments in lib/base.sh.
#
# [1] Nathaniel Landau, "My Mac OSX Bash Profile",
#     https://natelandau.com/my-mac-osx-bash_profile/, 2013-07-02.
#
#------------------------------------------------------------------------------
#  Description:  This file holds all general BASH aliases
#
#  For your own benefit, we won't load all aliases in the general, we will
#  keep the very generic command here and enough for daily basis tasks.
#
#  If you are looking for the more sexier aliases, we suggest you take a look
#  into other core alias files which installed by default.
#
#------------------------------------------------------------------------------

#   -----------------------------
#   1.  MAKE TERMINAL BETTER
#   -----------------------------

# Preferred 'cp' implementation.  Determines the use of the option `-v' on the
# first call Ref. https://github.com/ohmybash/oh-my-bash/issues/351
function _omb_util_alias_select_cp {
  if (tmp=$(_omb_util_mktemp); trap 'rm -f "$tmp"{,.2}' EXIT; command cp -v "$tmp" "$tmp.2" &>/dev/null); then
    _omb_command='cp -iv'
  else
    _omb_command='cp -i'
  fi
}
_omb_util_alias_delayed cp force

# Preferred 'mv' implementation
function _omb_util_alias_select_mv {
  if (tmp=$(_omb_util_mktemp); trap 'rm -f "$tmp.2"' EXIT; command mv -v "$tmp" "$tmp.2" &>/dev/null); then
    _omb_command='mv -iv'
  else
    _omb_command='mv -i'
  fi
}
_omb_util_alias_delayed mv force

# Preferred 'mkdir' implementation
function _omb_util_alias_select_mkdir {
  if command mkdir -pv . &>/dev/null; then
    _omb_command='mkdir -pv'
  else
    _omb_command='mkdir -p'
  fi
}
_omb_util_alias_delayed mkdir force

# Preferred 'nano' implementation
function _omb_util_alias_select_nano {
  if LANG=C command nano --help 2>/dev/null | grep -q '^[[:space:]]*[-]W'; then
    _omb_command='nano -W'
  else
    _omb_command='nano'
  fi
}
_omb_util_alias_delayed nano force

alias ll='ls -lAFh'                         # Preferred 'ls' implementation
alias less='less -FSRXc'                    # Preferred 'less' implementation
alias wget='wget -c'                        # Preferred 'wget' implementation (resume download)
alias c='clear'                             # c:            Clear terminal display
alias path='echo -e ${PATH//:/\\n}'         # path:         Echo all executable Paths
alias show_options='shopt'                  # Show_options: display bash options settings
alias fix_stty='stty sane'                  # fix_stty:     Restore terminal settings when screwed up
alias fix_term='echo -e "\033c"'            # fix_term:     Reset the conosle.  Similar to the reset command
alias cic='bind "set completion-ignore-case on"' # cic:          Make tab-completion case-insensitive
alias src='source ~/.bashrc'                # src:          Reload .bashrc file
