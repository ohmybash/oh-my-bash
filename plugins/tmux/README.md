# tmux

This plugin provides aliases for [tmux](https://github.com/tmux/tmux), the terminal multiplexer.

To use it, add `tmux` to the plugins array in your `.bashrc` file:

```bash
plugins=(... tmux)
```

## Aliases

| Alias      | Command                              | Description                                                 |
| ---------- | -------------------------------------| ----------------------------------------------------------- |
| `ta`       | `tmux attach -t`                     | Attach to a named tmux session                              |
| `tad`      | `tmux attach -d -t`                  | Detach and attach to a named tmux session                   |
| `tds`      | `_omb_plugin_tmux_directory_session` | Create or attach to a session named after current directory |
| `tkss`     | `tmux kill-session -t`               | Terminate a named running tmux session                      |
| `tksv`     | `tmux kill-server`                   | Terminate all running tmux sessions                         |
| `tl`       | `tmux list-sessions`                 | List running tmux sessions                                  |
| `to`       | `tmux new-session -A -s`             | Create or attach to a named tmux session                    |
| `ts`       | `tmux new-session -s`                | Create a new named tmux session                             |
| `tmuxconf` | `$EDITOR ~/.tmux.conf`               | Open the tmux config file in your editor                    |
