# bu

The `bu` plugin provides a small helper for moving up multiple directory levels with one command.

## Usage

```bash
bu N
```

`N` must be a positive integer. The command changes the current directory upward by `N` levels.

Examples:

```bash
bu 1  # cd ../
bu 2  # cd ../../
bu 3  # cd ../../../
```

## Enable

Add `bu` to the plugins list in your `.bashrc`:

To enable it together with other plugins like:

```bash
plugins=(... bu)
```

Reload your shell configuration after editing `.bashrc`:

```bash
source ~/.bashrc
```
