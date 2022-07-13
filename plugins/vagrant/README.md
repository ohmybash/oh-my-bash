# vagrant plugin

## Introduction

The `vagrant plugin` adds several useful aliases for [vagrant](https://www.vagrantup.com/downloads) commands and [aliases](#aliases).

To use them, add `vagrant` to the `plugins` array of your bashrc file:

```bash
plugins=(... vagrant)
```

## Aliases

| Command            | Description                                                  |
|:-------------------|:-------------------------------------------------------------|
| `va`               | command `vagrant`                                            |
| `vaver`            | Show the vagrant version in this host                        |
| `vaconf`           | command `vagrant ssh-config`                                 |
| `vastat`           | command `vagrant global-status`                              |
| `vacheck`          | command `vagrant validate`                                   |
| `vaport`           | command `vagrant port`                                       |
| `vapvm`            | command `vagrant plugin install *[ virtualbox \| libvirt ]*` |
| `vapi`             | command `vagrant plugin install *[ package ]*`               |
| `vapr`             | command `vagrant plugin uninstall *[ package ]*`             |
| `vau`              | command `vagrant up *[ virtualbox \| libvirt ]*`             |
| `vah`              | command `vagrant halt`                                       |
| `vat`              | command `vagrant destroy -f`                                 |
| `vai`              | command `vagrant init -m *[ centos/7 ]*`                     |
| `varel`            | command `vagrant reload`                                     |
| `vassh`            | command `vagrant ssh *[ machine1 ]*`                         |
| `vaba`             | command `vagrant box add`                                    |
| `vabr`             | command `vagrant box remove`                                 |
| `vabl`             | command `vagrant box list`                                   |
