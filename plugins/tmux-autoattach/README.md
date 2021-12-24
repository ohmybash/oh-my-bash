# tmux-autoattach.plugin

This tmux plugin will automatically attach a tmux session to your shell session.

## Variables

#### OSH_PLUGIN_TMUX_AUTOATTACH_BEHAVIOR

| Setting | Description                                                                                                                                                      |
|---------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `exit`    | This will completely close out your shell session, including your terminal, but keep your tmux sessions intact. This will also close your session if you detach. |
| `detach` (default)  | This will allow you to detach from the tmux screen without closing the terminal or shell session.                                                                |
