# wake

This plugin provides a wrapper around the `wakeonlan` tool available from most
distributions' package repositories, or from [this website](https://github.com/jpoliv/wakeonlan).

To use it, add `wake` to the plugins array in your **~/.bashrc**:

```bash
plugins=(... wake)
```

## Configuration

Create the `~/.wakeonlan` directory and place **one file per device** you want to wake.
The filename is the device name (used on the CLI and in completion).

**Two file formats are supported** (comments and blank lines are ignored):

**A) Single-line format**
```
<MAC> [broadcast-IP] [port]
```

**B) key=value format**
```
MAC=aa:bb:cc:dd:ee:ff
BCAST=192.168.0.255
PORT=9
# comments allowed
```

**Defaults:** if `BCAST` is omitted → `255.255.255.255`; if `PORT` is omitted → `9`.

**Example** (`~/.wakeonlan/server`):

```
00:11:22:33:44:55 192.168.0.255 9
```

or

```
MAC=00:11:22:33:44:55
BCAST=192.168.0.255
PORT=9
```

> Tip: device names can contain spaces, but you’ll need quotes when calling (e.g., `wake "my server"`).

## Usage

```
wake [options] <device>
```

### Options

| Option            | Description                                 | Default |
|-------------------|---------------------------------------------|---------|
| `-l`, `--list`    | List configured device names and exit       | —       |
| `-n`, `--dry-run` | Show the command that would be executed     | —       |
| `-p`, `--port N`  | Override UDP port                           | `9`     |
| `-h`, `--help`    | Show usage                                  | —       |

### Examples

Wake a device:
```bash
wake server
```

List devices:
```bash
wake -l
```

Dry-run (don’t send a packet, just show the command):
```bash
wake -n server
# DRY-RUN: wakeonlan -p 9 -i 192.168.0.255 00:11:22:33:44:55
```

Use a non-default port:
```bash
wake -p 7 server
```

**Autocompletion:** device names from `~/.wakeonlan` are autocompleted:
```bash
wake <TAB>
```

**No-arg behavior:** running `wake` without arguments prints usage and shows available
devices (and exits with code 1). Use `wake -l` for a clean list and exit code 0.

## Installing `wakeonlan`

If your distro doesn’t provide `wakeonlan`, install it manually from GitHub:

```bash
curl -RLOJ https://github.com/jpoliv/wakeonlan/raw/refs/heads/master/wakeonlan
chmod a+x wakeonlan
sudo install -o root -g root -m 755 wakeonlan /usr/local/bin/wakeonlan
rm wakeonlan
```

Enjoy!
