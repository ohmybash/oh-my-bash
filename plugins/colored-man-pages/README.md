# Colored Man Pages Plugin

Adds colors to [`man`](https://man7.org/linux/man-pages/man1/man.1.html) pages.

To use it, add `colored-man-pages` to the plugins array in your .bashrc file.

```bash
plugins=(... colored-man-pages)
```

It will also automatically colorize man pages displayed by `dman` or `debman`,
from [`debian-goodies`](https://packages.debian.org/stable/debian-goodies).

You can also try to color other pages by prefixing the respective command with `colored`:

```bash
colored git help clone
```
