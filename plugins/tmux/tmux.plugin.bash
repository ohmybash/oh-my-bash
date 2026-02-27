#! bash oh-my-bash.module

# tmux plugin: aliases for tmux, the terminal multiplexer.
# Last reference implementation link:
# https://github.com/ohmyzsh/ohmyzsh/blob/5c4f27b7166360bd23709f24642b247eac30a147/plugins/tmux/tmux.plugin.zsh
#
# Dropped features from upstream:
#   - alias tmux -> _zsh_tmux_plugin_run (tmux wrapper with autostart/autoconnect)
#   - function _zsh_tmux_plugin_run (autostart, autoconnect, autoquit, TERM fixing)
#   - function _zsh_tmux_plugin_preexec (refresh tmux environment variables)
#   - function _build_tmux_alias (zsh completion wiring)
#   - ZSH_TMUX_* configuration variables (AUTOSTART, AUTOCONNECT, AUTOQUIT,
#     AUTONAME_SESSION, AUTOREFRESH, CONFIG, DEFAULT_SESSION_NAME, DETACHED,
#     FIXTERM, FIXTERM_WITHOUT_256COLOR, FIXTERM_WITH_256COLOR, ITERM2, UNICODE)
#   - tmux.extra.conf, tmux.only.conf (TERM fix config files)

if ! _omb_util_command_exists tmux; then
  _omb_util_print '[oh-my-bash] tmux not found, please install it from https://github.com/tmux/tmux' >&2
  return 0
fi

# Aliases
alias ta='tmux attach -t'
alias tad='tmux attach -d -t'
alias tkss='tmux kill-session -t'
alias tksv='tmux kill-server'
alias tl='tmux list-sessions'
alias ts='tmux new-session -s'
alias to='tmux new-session -A -s'
alias tmuxconf='${EDITOR:-vim} ~/.tmux.conf'

# Create or attach to a tmux session named after the current directory.
function _omb_plugin_tmux_directory_session {
  local dir=${PWD##*/}
  local md5
  if _omb_util_command_exists md5sum; then
    md5=$(printf '%s' "$PWD" | md5sum | cut -d ' ' -f 1)
  elif _omb_util_command_exists md5; then
    md5=$(printf '%s' "$PWD" | md5)
  else
    _omb_util_print '[oh-my-bash] tmux plugin: md5sum or md5 not found, tds requires one of them' >&2
    return 1
  fi
  local session_name="${dir}-${md5:0:6}"
  tmux new-session -As "$session_name"
}

alias tds='_omb_plugin_tmux_directory_session'
