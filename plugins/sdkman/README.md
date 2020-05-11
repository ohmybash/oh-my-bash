# sdkman plugin

This plugin automatically source sdkman[1]

## Installation

### Install sdkman

Lets install[2] the sdkman without updaing shell config!

```bash
$ curl -s "https://get.sdkman.io?rcupdate=false" | bash
```

### Include sdkman as plugin

```bash
plugins=(
  git
  sdkman
)
```

[1]: https://sdkman.io/
[2]: https://sdkman.io/install
