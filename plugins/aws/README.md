# aws

The `aws` plugin provides small helpers for working with AWS CLI profiles.

## Features

- Sets `AWS_HOME` to `~/.aws`.
- Adds `agp` to print the currently selected AWS profile.
- Adds `asp PROFILE` to switch the active AWS profile for the current shell.

## Usage

Print the current profile:

```bash
agp
```

Switch to another profile:

```bash
asp production
```

This sets both `AWS_DEFAULT_PROFILE` and `AWS_PROFILE` to the profile name you pass in.

## Enable

Add `aws` to the plugins array in your `.bashrc` file:

```bash
plugins=(... aws)
```

Reload your shell configuration after editing `.bashrc`:

```bash
source ~/.bashrc
```

## Requirements

This plugin is intended for use with the [AWS CLI](https://aws.amazon.com/cli/). Make sure your AWS profiles are configured under `~/.aws` before using `asp`.
