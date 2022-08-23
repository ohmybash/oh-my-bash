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

# Determines the use of the option `-v' on the first call
# Ref. https://github.com/ohmybash/oh-my-bash/issues/351
function _omb_alias_general_cp_init {
  if (tmp=$(_omb_util_mktemp); trap 'rm -f "$tmp"{,.2}' EXIT; command cp -v "$tmp" "$tmp.2" &>/dev/null); then
    alias cp='cp -iv' && unset -f "$FUNCNAME"
    command cp -iv "$@"
  else
    alias cp='cp -i' && unset -f "$FUNCNAME"
    command cp -i "$@"
  fi
}
function _omb_alias_general_mv_init {
  if (tmp=$(_omb_util_mktemp); trap 'rm -f "$tmp.2"' EXIT; command mv -v "$tmp" "$tmp.2" &>/dev/null); then
    alias mv='mv -iv' && unset -f "$FUNCNAME"
    command mv -iv "$@"
  else
    alias mv='mv -i' && unset -f "$FUNCNAME"
    command mv -i "$@"
  fi
}
function _omb_alias_general_mkdir_init {
  if command mkdir -pv . &>/dev/null; then
    alias mkdir='mkdir -pv' && unset -f "$FUNCNAME"
    command mkdir -pv "$@"
  else
    alias mkdir='mkdir -p' && unset -f "$FUNCNAME"
    command mkdir -p "$@"
  fi
}

alias cp='_omb_alias_general_cp_init'       # Preferred 'cp' implementation
alias mv='_omb_alias_general_mv_init'       # Preferred 'mv' implementation
alias mkdir='_omb_alias_general_mkdir_init' # Preferred 'mkdir' implementation
alias ll='ls -lAFh'                         # Preferred 'ls' implementation
alias less='less -FSRXc'                    # Preferred 'less' implementation
alias nano='nano -W'                        # Preferred 'nano' implementation
alias wget='wget -c'                        # Preferred 'wget' implementation (resume download)
alias c='clear'                             # c:            Clear terminal display
alias path='echo -e ${PATH//:/\\n}'         # path:         Echo all executable Paths
alias show_options='shopt'                  # Show_options: display bash options settings
alias fix_stty='stty sane'                  # fix_stty:     Restore terminal settings when screwed up
alias fix_term='echo -e "\033c"'            # fix_term:     Reset the conosle.  Similar to the reset command
alias cic='set completion-ignore-case On'   # cic:          Make tab-completion case-insensitive
alias src='source ~/.bashrc'                # src:          Reload .bashrc file
