# ssh-agent plugin

This plugin starts `ssh-agent` once and shares it across all your shells, and
loads your SSH keys into it.  It is derived from the ssh-agent plugin of
Oh My Zsh.

To use it, add `ssh-agent` to the plugins array in your `~/.bashrc`:

```bash
plugins=(... ssh-agent)
```

When a shell starts, the plugin

1. reuses the agent pointed to by `SSH_AUTH_SOCK` if it is reachable (e.g. a
   forwarded agent or one started by your desktop session),
2. otherwise reuses the agent recorded in `~/.ssh/environment-<hostname>`,
3. otherwise starts a new agent and records it in that file.

Then it loads the keys that are not yet in the agent, so you are asked for
each passphrase only once.  The environment file is per host, so a home
directory shared over NFS works across machines.

## Settings

Set these in `~/.bashrc` before `source "$OSH"/oh-my-bash.sh`.

| Variable                           | Description                                                                                                                         |
|------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| `OMB_PLUGIN_SSH_AGENT_IDENTITIES`  | Array of key files to load.  Names are relative to `~/.ssh` unless absolute.  Default: those of `id_rsa`, `id_dsa`, `id_ecdsa`, `id_ecdsa_sk`, `id_ed25519` and `id_ed25519_sk` that exist. |
| `OMB_PLUGIN_SSH_AGENT_LIFETIME`    | Maximum lifetime of the loaded keys, e.g. `4h`.  Passed to `ssh-agent -t` and `ssh-add -t`.                                         |
| `OMB_PLUGIN_SSH_AGENT_LAZY`        | If `yes`, start the agent but do not load keys at startup.  Combine it with `AddKeysToAgent yes` in `~/.ssh/config`.                |
| `OMB_PLUGIN_SSH_AGENT_QUIET`       | If `yes`, suppress the messages of `ssh-add`.                                                                                       |
| `OMB_PLUGIN_SSH_AGENT_ADD_ARGS`    | Array of extra arguments to `ssh-add`, e.g. `(--apple-use-keychain)` on macOS.                                                      |

Example:

```bash
OMB_PLUGIN_SSH_AGENT_IDENTITIES=(id_ed25519 work_id_rsa)
OMB_PLUGIN_SSH_AGENT_LIFETIME=8h
plugins=(git ssh-agent)
```
