# kube-ps1 plugin

Displays the current [Kubernetes](https://kubernetes.io) context and namespace
in the shell prompt.

This plugin is a derivative work of
[kube-ps1](https://github.com/jonmosco/kube-ps1) by Jon Mosco, adapted for
Oh My Bash.

## License & notices

The original `kube-ps1` is Copyright 2020 Jon Mosco and is distributed under
the [Apache License, Version 2.0](LICENSE).  A copy of that license is
included in this directory (`plugins/kube-ps1/LICENSE`).

This adapted version is also provided under the Apache License 2.0 alongside
the MIT license that covers Oh My Bash as a whole.

The original script can be found at
<https://github.com/jonmosco/kube-ps1/blob/master/kube-ps1.sh>.

---

## Requirements

* `kubectl` (or the binary set in `KUBE_PS1_BINARY`) must be installed and
  reachable in `$PATH`.

## Enable the plugin

Add `kube-ps1` to the `plugins` array in your `~/.bashrc`:

```bash
plugins=(... kube-ps1)
```

## How the segment appears in your prompt

Enabling the plugin is all that is required — no changes to `PS1` are needed.
The plugin automatically prepends the kube segment to whatever `PS1` your
active theme sets, on every command.

If you prefer to control the exact position of the segment yourself (e.g.
from a custom theme or a hand-crafted `PS1`), embed `$(kube_ps1)` literally:

```bash
PS1='[\u@\h \W $(kube_ps1)]\$ '
```

> **Note:** do not do both. When `$(kube_ps1)` is already present in `PS1`
> literally, the automatic injection is skipped to prevent duplication.

## Commands

| Command         | Description                                          |
|:----------------|:-----------------------------------------------------|
| `kubeon`        | Enable the kube-ps1 prompt for this shell session    |
| `kubeon -g`     | Enable the kube-ps1 prompt globally (persistent)     |
| `kubeoff`       | Disable the kube-ps1 prompt for this shell session   |
| `kubeoff -g`    | Disable the kube-ps1 prompt globally (persistent)    |

## Configuration

All variables can be set in `~/.bashrc` **before** oh-my-bash is sourced.

### Display

| Variable                    | Default   | Description                                           |
|:----------------------------|:----------|:------------------------------------------------------|
| `KUBE_PS1_BINARY`           | `kubectl` | Binary used to read context/namespace                 |
| `KUBE_PS1_SYMBOL_ENABLE`    | `true`    | Show/hide the Kubernetes symbol (⎈)                   |
| `KUBE_PS1_SYMBOL_PADDING`   | `false`   | Add a trailing space after the symbol                 |
| `KUBE_PS1_SYMBOL_CUSTOM`    | _(empty)_ | Use a custom symbol: `img`, `k8s`, `oc`, or any char  |
| `KUBE_PS1_CONTEXT_ENABLE`   | `true`    | Show/hide the context name                            |
| `KUBE_PS1_NS_ENABLE`        | `true`    | Show/hide the namespace name                          |
| `KUBE_PS1_PREFIX`           | `(`       | String prepended to the prompt segment                |
| `KUBE_PS1_SUFFIX`           | `)`       | String appended to the prompt segment                 |
| `KUBE_PS1_SEPARATOR`        | `\|`      | Separator between symbol and context                  |
| `KUBE_PS1_DIVIDER`          | `:`       | Separator between context and namespace               |
| `KUBE_PS1_HIDE_IF_NOCONTEXT`| `false`   | Hide the segment entirely when no context is active   |

### Colours

| Variable                | Default   | Description                                              |
|:------------------------|:----------|:---------------------------------------------------------|
| `KUBE_PS1_CTX_COLOR`    | `red`     | Context name colour                                      |
| `KUBE_PS1_NS_COLOR`     | `cyan`    | Namespace colour                                         |
| `KUBE_PS1_SYMBOL_COLOR` | `blue`    | Symbol colour                                            |
| `KUBE_PS1_PREFIX_COLOR` | _(empty)_ | Prefix colour (empty = no colour code)                   |
| `KUBE_PS1_SUFFIX_COLOR` | _(empty)_ | Suffix colour (empty = no colour code)                   |
| `KUBE_PS1_BG_COLOR`     | _(empty)_ | Background colour for the whole segment                  |

Accepted colour values: `black`, `red`, `green`, `yellow`, `blue`,
`magenta`, `cyan`, `white`, or an integer `0`–`255` for 256-colour
terminals.

### Custom functions

You can provide shell functions to dynamically transform or colour values:

| Variable                      | Signature                              | Description                                       |
|:------------------------------|:---------------------------------------|:--------------------------------------------------|
| `KUBE_PS1_CLUSTER_FUNCTION`   | `my_fn <context>  → string`            | Transform the context name before display         |
| `KUBE_PS1_NAMESPACE_FUNCTION` | `my_fn <namespace> → string`           | Transform the namespace before display            |
| `KUBE_PS1_CTX_COLOR_FUNCTION` | `my_fn <context>  → colour`            | Return a colour name/number for the context       |

## Example

```bash
# ~/.bashrc

# Show only the last segment of the context name
kube_short_ctx() { printf '%s' "${1##*/}"; }
export KUBE_PS1_CLUSTER_FUNCTION=kube_short_ctx

plugins=(... kube-ps1)
source "$OSH"/oh-my-bash.sh

PS1='[\u@\h \W $(kube_ps1)]\$ '
```
