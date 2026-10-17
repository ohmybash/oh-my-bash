#! bash oh-my-bash.module
#
# ssh-agent.plugin.sh
#
# Start ssh-agent once and share it across shells, and load the SSH keys into
# it.  This plugin is derived from the ssh-agent plugin of Oh My Zsh.
#
# Variables:
#
#   OMB_PLUGIN_SSH_AGENT_IDENTITIES  (array) Key files to load.  Names are
#                                    relative to ~/.ssh unless absolute.
#                                    Default: the standard id_* keys that exist.
#   OMB_PLUGIN_SSH_AGENT_LIFETIME    Maximum lifetime of the loaded keys, e.g.
#                                    "4h" (passed to ssh-agent/ssh-add -t).
#   OMB_PLUGIN_SSH_AGENT_LAZY        If "yes", start the agent but do not load
#                                    keys (use "AddKeysToAgent yes" instead).
#   OMB_PLUGIN_SSH_AGENT_QUIET       If "yes", suppress the ssh-add messages.
#   OMB_PLUGIN_SSH_AGENT_ADD_ARGS    (array) Extra arguments to ssh-add.

_omb_util_command_exists ssh-agent || return 0
_omb_util_command_exists ssh-add || return 0

_omb_plugin_ssh_agent_env=$HOME/.ssh/environment-${HOSTNAME%%.*}

# ssh-add -l exits with 2 when it cannot connect to the agent.
function _omb_plugin_ssh_agent__is_alive {
  [[ ${SSH_AUTH_SOCK-} ]] || return 1
  ssh-add -l >/dev/null 2>&1
  (($? != 2))
}

# Read SSH_AUTH_SOCK and SSH_AGENT_PID from ssh-agent's output (from stdin)
# without executing it.
function _omb_plugin_ssh_agent__load_env {
  local line re='^(SSH_AUTH_SOCK|SSH_AGENT_PID)=([^;]*);'
  while IFS= read -r line; do
    [[ $line =~ $re ]] || continue
    export "${BASH_REMATCH[1]}=${BASH_REMATCH[2]}"
  done
}

# Load the environment file only if it is our own regular file.
function _omb_plugin_ssh_agent__load_env_file {
  local file=$_omb_plugin_ssh_agent_env
  [[ -f $file && ! -L $file && -O $file ]] || return 1
  _omb_plugin_ssh_agent__load_env < "$file"
}

function _omb_plugin_ssh_agent__start {
  # Reuse a reachable agent: a forwarded one, one started by the desktop
  # session, or the one shared through the environment file.
  _omb_plugin_ssh_agent__is_alive && return 0
  _omb_plugin_ssh_agent__load_env_file && _omb_plugin_ssh_agent__is_alive && return 0

  [[ -d $HOME/.ssh ]] || mkdir -m 700 "$HOME/.ssh" || return 1

  # Serialize the agent creation among shells starting at the same time.  A
  # lock left by a killed shell is taken over after about 5 seconds.
  local lock=$_omb_plugin_ssh_agent_env.lock i
  for ((i = 0; i < 50; i++)); do
    mkdir "$lock" 2>/dev/null && break
    sleep 0.1
  done

  local ret=0
  if ! { _omb_plugin_ssh_agent__load_env_file && _omb_plugin_ssh_agent__is_alive; }; then
    local -a args=(-s)
    [[ ${OMB_PLUGIN_SSH_AGENT_LIFETIME-} ]] && args+=(-t "$OMB_PLUGIN_SSH_AGENT_LIFETIME")

    local out tmp=$_omb_plugin_ssh_agent_env.$$
    if out=$(ssh-agent "${args[@]}") &&
      (umask 077 && command sed '/^echo/d' <<< "$out" >| "$tmp") &&
      command mv -f "$tmp" "$_omb_plugin_ssh_agent_env"
    then
      _omb_plugin_ssh_agent__load_env <<< "$out"
      _omb_plugin_ssh_agent__is_alive || ret=1
    else
      command rm -f "$tmp"
      ret=1
    fi
  fi

  rmdir "$lock" 2>/dev/null
  return "$ret"
}

function _omb_plugin_ssh_agent__add_identities {
  local -a ids
  if [[ ${OMB_PLUGIN_SSH_AGENT_IDENTITIES+set} ]]; then
    ids=("${OMB_PLUGIN_SSH_AGENT_IDENTITIES[@]}")
  else
    ids=(id_rsa id_dsa id_ecdsa id_ecdsa_sk id_ed25519 id_ed25519_sk)
  fi

  # Fingerprints of the keys already in the agent
  local loaded
  loaded=$(ssh-add -l 2>/dev/null | command awk '{print $2}')

  local -a files=()
  local id file fingerprint
  for id in "${ids[@]}"; do
    [[ $id == /* ]] && file=$id || file=$HOME/.ssh/$id
    [[ -f $file ]] || continue
    fingerprint=$(ssh-keygen -lf "$file" 2>/dev/null | command awk '{print $2}')
    [[ $fingerprint && $'\n'$loaded$'\n' == *$'\n'"$fingerprint"$'\n'* ]] && continue
    files+=("$file")
  done
  ((${#files[@]})) || return 0

  local -a args=()
  [[ ${OMB_PLUGIN_SSH_AGENT_QUIET-} == yes ]] && args+=(-q)
  [[ ${OMB_PLUGIN_SSH_AGENT_LIFETIME-} ]] && args+=(-t "$OMB_PLUGIN_SSH_AGENT_LIFETIME")
  [[ ${OMB_PLUGIN_SSH_AGENT_ADD_ARGS+set} ]] && args+=("${OMB_PLUGIN_SSH_AGENT_ADD_ARGS[@]}")
  ssh-add "${args[@]}" "${files[@]}"
}

if _omb_plugin_ssh_agent__start; then
  [[ ${OMB_PLUGIN_SSH_AGENT_LAZY-} == yes ]] || _omb_plugin_ssh_agent__add_identities
fi
