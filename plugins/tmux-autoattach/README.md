# tmux-autoattach.plugin

This tmux plugin will automatically attach a tmux session to your shell session.

## Variables

#### OSH_PLUGIN_TMUX_AUTOATTACH_BEHAVIOR

| Setting            | Description                                                                                                                                                      |
|--------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `detach` (default) | This will allow you to detach from the tmux screen without closing the terminal or shell session.                                                                |
| `exit`             | This will completely close out your shell session, including your terminal, but keep your tmux sessions intact. This will also close your session if you detach. |

## Common Enable Conditions

*Note* If you prefer to manually start your desktop session using tools like `startx`, you may run into problems starting your desktop session inside of a tmux terminal. You can employ conditionals to control when this plugin should be enabled.

**SSH**

```bash
[ "$SSH_TTY" ] && plugins+=(tmux-autoattach)
```

**Wayland**

```bash
[ "$DISPLAY_WAYLAND" ] && plugins+=(tmux-autoattach)
```

**X11**

```bash
[ "$DISPLAY" ] && plugins+=(tmux-autoattach)
```

**Multiple**

```bash
if [ "$DISPLAY" ] || [ "$SSH" ]; then
  plugins+=(tmux-autoattach)
fi
```
