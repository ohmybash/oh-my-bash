# tmux plugin

The tmux plugin will either attach or create a new tmux session for each bash session. If a session already exists, it will simply attach.

## OSH_PLUGIN_TMUX_AUTOATTACH_BEHAVIOR

| exit   | This will completely close out your shell session, including your terminal, but keep your tmux sessions intact. This will also close your session if you detach. |
| detach | This will allow you to detach from the tmux screen without closing the terminal or shell session.                                                                |
