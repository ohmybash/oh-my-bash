# golang plugin

Add [oh-my-bash](https://ohmybash.github.io) integration for [Go](https://golang.org/) development, providing aliases and utility functions for common Go workflows. Inspired by the [oh-my-zsh golang plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/golang).

## Installation

Enable the plugin by adding it to your oh-my-bash `plugins` definition in `~/.bashrc`.

```sh
plugins=(golang)
```

> **Note:** Tab completion for Go commands is included automatically — no separate `completions=(go)` entry is needed.

## Aliases

### Build

| Alias  | Command          | Description                              |
|--------|------------------|------------------------------------------|
| `gob`  | `go build`       | Build the current package                |
| `goba` | `go build ./...` | Build all packages recursively           |

### Clean

| Alias | Command    | Description                              |
|-------|------------|------------------------------------------|
| `goc` | `go clean` | Remove object files and cached files     |

### Doc / Env / Fix

| Alias  | Command    | Description                              |
|--------|------------|------------------------------------------|
| `god`  | `go doc`   | Show documentation for a package/symbol  |
| `goe`  | `go env`   | Print Go environment information         |
| `gofx` | `go fix`   | Update packages to use new APIs          |

### Format

| Alias  | Command          | Description                              |
|--------|------------------|------------------------------------------|
| `gof`  | `go fmt`         | Format the current package               |
| `gofa` | `go fmt ./...`   | Format all packages recursively          |

### Get / Install

| Alias  | Command          | Description                                     |
|--------|------------------|-------------------------------------------------|
| `gog`  | `go get`         | Download and install packages                   |
| `goga` | `go get ./...`   | Download and install all packages recursively   |
| `goi`  | `go install`     | Compile and install packages to `$GOPATH`       |

### List / Mod

| Alias  | Command            | Description                              |
|--------|--------------------|------------------------------------------|
| `gol`  | `go list`          | List packages or modules                 |
| `gom`  | `go mod`           | Module maintenance                       |
| `gomt` | `go mod tidy`      | Add missing and remove unused modules    |
| `gomi` | `go mod init`      | Initialize a new module                  |
| `gomv` | `go mod vendor`    | Make a vendored copy of dependencies     |

### Run

| Alias | Command  | Description                     |
|-------|----------|---------------------------------|
| `gor` | `go run` | Compile and run a Go program    |

### Test

| Alias   | Command              | Description                              |
|---------|----------------------|------------------------------------------|
| `got`   | `go test`            | Run tests                                |
| `gota`  | `go test ./...`      | Run all tests recursively                |
| `gotv`  | `go test -v`         | Run tests with verbose output            |
| `gotva` | `go test -v ./...`   | Run all tests recursively with verbosity |

### Tool

| Alias    | Command              | Description                              |
|----------|----------------------|------------------------------------------|
| `goto`   | `go tool`            | Run a specific Go tool                   |
| `gotoc`  | `go tool compile`    | Compile Go source files                  |
| `gotod`  | `go tool dist`       | Bootstrap and distribution tool          |
| `gotofx` | `go tool fix`        | Find and fix outdated API usage          |

### Vet / Version / Work

| Alias  | Command        | Description                              |
|--------|----------------|------------------------------------------|
| `gov`  | `go vet`       | Report suspicious code constructs        |
| `gova` | `go vet ./...` | Vet all packages recursively             |
| `gove` | `go version`   | Print the current Go version             |
| `gow`  | `go work`      | Workspace maintenance                    |

### Navigation

| Alias  | Command             | Description                          |
|--------|---------------------|--------------------------------------|
| `gop`  | `cd $GOPATH`        | Go to `$GOPATH`                      |
| `gopb` | `cd $GOPATH/bin`    | Go to `$GOPATH/bin`                  |
| `gops` | `cd $GOPATH/src`    | Go to `$GOPATH/src`                  |

## Utility functions

### `gocd <package>`

Navigate to a package's source directory under `$GOPATH/src`. Prints a clear error if `GOPATH` is not set.

```bash
gocd github.com/some/package
```

### `gocov [-flags...] [packages]`

Run tests with a coverage report and open the result in your browser. Flags (arguments starting with `-`) are forwarded to `go test`; remaining arguments are treated as packages. If no packages are given, `./...` is used as the default.

```bash
gocov                      # test ./... + open coverage report
gocov ./pkg/...            # test a specific subtree
gocov -run=TestFoo         # run a specific test across ./...
gocov -run=TestFoo ./pkg/... # run a specific test in a subtree
```
