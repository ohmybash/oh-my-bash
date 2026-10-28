# python-m plugin

The `python-m` plugin provides completion when for dotted Python module path (`pkg.module`) after `python3 -m` and `python -m`.

To use it, add `python-m` to the plugin array of your bashrc file:

```bash
plugins=(... python-m)
```


## Example

In a directory with this tree:

```
.
└── pkg
    ├── __pycache__
    │   └── ...
    ├── __init__.py
    ├── module1.py
    ├── module2.py
    └── display.py
```

```bash
$ python3 -m pkg.<tab>
pkg.display   pkg.__init__  pkg.module1   pkg.module2
```

```bash
$ python3 -m pkg.mo<tab>
pkg.module1  pkg.module2
```
