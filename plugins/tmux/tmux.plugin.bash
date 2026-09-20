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

# Generate a short hash for the current directory path.
# Uses md5sum (Linux) or md5 -q (macOS/BSD) to get a consistent 6-char prefix.
function _omb_plugin_tmux_dir_hash {
  local md5
  if _omb_util_command_exists md5sum; then
    md5=$(printf '%s' "$PWD" | md5sum | cut -d ' ' -f 1)
  elif _omb_util_command_exists md5; then
    # macOS/BSD md5 requires -q for quiet/raw output
    md5=$(printf '%s' "$PWD" | md5 -q)
  else
    _omb_util_print '[oh-my-bash] tmux plugin: md5sum or md5 not found, tds/tdss require one of them' >&2
    return 1
  fi
  printf '%s' "${md5:0:6}"
}

# Create or attach to a tmux session named after the current directory with an optional suffix.
function _omb_plugin_tmux_directory_session {
  local dir=${PWD##*/}
  local hash
  hash=$(_omb_plugin_tmux_dir_hash) || return 1
  local suffix="${1:-}"
  local session_name="${dir}-${hash}"
  [[ -n "$suffix" ]] && session_name="${session_name}-${suffix}"
  tmux new-session -As "$session_name"
}

alias tds='_omb_plugin_tmux_directory_session'

# Discoverable alias for creating suffixed directory sessions.
alias tdss='_omb_plugin_tmux_directory_session'

# Autocomplete for tmux aliases (ta, tad, tkss)
# Compare shell-escaped session names against both forms Bash can provide for
# the current word: raw text and text containing command-line escapes.
function _omb_plugin_tmux_alias_sessions {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local escaped_cur
  printf -v escaped_cur '%q' "$cur"

  local -a sessions
  _omb_util_split_lines sessions "$(tmux list-sessions -F '#S' 2>/dev/null)"

  COMPREPLY=()
  local s escaped
  for s in "${sessions[@]}"; do
    printf -v escaped '%q' "$s"
    [[ $escaped == "$cur"* || $escaped == "$escaped_cur"* ]] || continue
    COMPREPLY+=("$escaped")
  done
}

complete -F _omb_plugin_tmux_alias_sessions ta tad tkss
