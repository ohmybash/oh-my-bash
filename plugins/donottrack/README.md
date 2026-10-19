# Do Not Track plugin

Many command line applications send telemetry with anonymous usage statistics. Most
of them can be told not to through an environment variable. This plugin exports those
variables for you.

To use it, add `donottrack` to your plugins array in your bashrc file:

```bash
plugins=(... donottrack)
```

Variables that are already set in your environment are never overwritten, so you
can opt back in to any single tool by exporting its variable before Oh My Bash
is loaded:

```bash
export HOMEBREW_NO_ANALYTICS=0

source "$OSH/oh-my-bash.sh"
```

## Resources

- [Toptout](https://toptout.me)
- [DO_NOT_TRACK](https://donottrack.sh)
