Oh My Bash is an open source, community-driven framework for managing your [bash](https://www.gnu.org/software/bash/) configuration.

Sounds boring. Let's try again.

Oh My Bash will not make you a 10x developer...but you might feel like one.

Once installed, your terminal shell will become the talk of the town or your money back! With each keystroke in your command prompt, you'll take advantage of the hundreds of powerful plugins and beautiful themes. Strangers will come up to you in cafés and ask you, "that is amazing! are you some sort of genius?"

Finally, you'll begin to get the sort of attention that you have always felt you deserved. ...or maybe you'll use the time that you're saving to start flossing more often.

## Getting Started

### Prerequisites

__Disclaimer:__ _Oh My Bash works best on macOS and Linux._

* Unix-like operating system (macOS or Linux)
* `curl` or `wget` should be installed
* `git` should be installed

### Basic Installation

Oh My Bash is installed by running one of the following commands in your terminal. You can install this via the command-line with either `curl` or `wget`.

#### via curl

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

#### via wget

```shell
bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
```

This replaces `~/.bashrc` with the version provided by Oh My Bash. The original `.bashrc` is backed up with the name `~/.bashrc.omb-TIMESTAMP`.
If `~/.bash_profile` does not exist, this also creates a new file `~/.bash_profile` with the default contents.

⚠️ If `~/.bash_profile` already existed before Oh My Bash is installed, please make sure that`~/.bash_profile` contains the line `source ~/.bashrc` or `. ~/.bashrc`.
If not, please add the following three lines in `~/.bash_profile`:
```bash
if [[ -f ~/.bashrc ]]; then
  source ~/.bashrc
fi
```

## Using Oh My Bash

### Plugins

Oh My Bash comes with a shit load of plugins to take advantage of. You can take a look in the [plugins](https://github.com/ohmybash/oh-my-bash/tree/master/plugins) directory and/or the [wiki](https://github.com/ohmybash/oh-my-bash/wiki/Plugins) to see what's currently available.

#### Enabling Plugins

Once you spot a plugin (or several) that you'd like to use with Oh My Bash, you'll need to enable them in the `.bashrc` file. You'll find the bashrc file in your `$HOME` directory. Open it with your favorite text editor and you'll see a spot to list all the plugins you want to load.

For example, this line might begin to look like this:

```shell
plugins=(git bundler osx rake ruby)
```

##### With Conditionals

You may want to control when and/or how plugins should be enabled.

For example, if you want the `tmux-autoattach` plugin to only run on SSH sessions, you could employ a trivial conditional that checks for the `$SSH_TTY` variable. Just make sure to remove the plugin from the larger plugin list.

``` bash
[ "$SSH_TTY" ] && plugins+=(tmux-autoattach)
```

#### Using Plugins

Most plugins (should! we're working on this) include a __README__, which documents how to use them.

### Themes

We'll admit it. Early in the Oh My Bash world, we may have gotten a bit too theme happy. We have over one hundred themes now bundled. Most of them have [screenshots](https://github.com/ohmybash/oh-my-bash/wiki/Themes) on our wiki or alternatively [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh/wiki/themes) wiki.

#### Selecting a Theme

_Powerline's theme is the default one. It's not the fanciest one. It's not the simplest one. It's just the right one (for me)._

Once you find a theme that you want to use, you will need to edit the `~/.bashrc` file. You'll see an environment variable (all caps) in there that looks like:

```shell
OSH_THEME="powerline"
```

To use a different theme, simply change the value to match the name of your desired theme. For example:

```shell
OSH_THEME="agnoster" # (this is one of the fancy ones)
# you might need to install a special Powerline font on your console's host for this to work
# see https://github.com/ohmybash/oh-my-bash/wiki/Themes#agnoster
```

Open up a new terminal window and your prompt should look something like this:

![Agnoster theme](img/example_powerline.png)

In case you did not find a suitable theme for your needs, please have a look at the wiki for [more of them](https://github.com/ohmybash/oh-my-bash/wiki/External-themes).

If you're feeling feisty, you can let the computer select one randomly for you each time you open a new terminal window.

```shell
OSH_THEME="random" # (...please let it be pie... please be some pie..)
```

If there are themes you don't like, you can add them to an ignored list:

```shell
OMB_THEME_RANDOM_IGNORED=("powerbash10k" "wanelo")
```

The selected theme name can be checked by the following command:

```shell
$ echo "$OMB_THEME_RANDOM_SELECTED"
```

## Advanced Topics

If you're the type that likes to get their hands dirty, these sections might resonate.

### Advanced Installation

Some users may want to change the default path, or manually install Oh My Bash.

#### Custom Directory

The default location is `~/.oh-my-bash` (hidden in your home directory)

If you'd like to change the install directory with the `OSH` environment variable, either by running `export OSH=/your/path` before installing, or by setting it before the end of the install pipeline like this:

```shell
export OSH="$HOME/.dotfiles/oh-my-bash"; bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

#### Unattended install

If you're running the Oh My Bash install script as part of an automated install, you can pass the
flag `--unattended` to the `install.sh` script. This will have the effect of not trying to change
the default shell, and also won't run `bash` when the installation has finished.

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
```

#### System-wide installation

For example, Oh My Bash can be installed to `/usr/local/share/oh-my-bash` for the system-wide installation by specifying the option `--prefix=PREFIX`.

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --prefix=/usr/local
```

To enable Oh My Bash, the Bash startup file `.bashrc` needs to be manually set up by each user.
The template of `.bashrc` is available in `PREFIX/share/oh-my-bash/bashrc`.
The users can copy the template file to `~/.bashrc` and edit it.

```bash
cp /usr/local/share/oh-my-bash/bashrc ~/.bashrc
```

#### Manual Installation

##### 1. Clone the repository:

```shell
git clone https://github.com/ohmybash/oh-my-bash.git ~/.oh-my-bash
```

##### 2. *Optionally*, backup your existing `~/.bashrc` file:

```shell
cp ~/.bashrc ~/.bashrc.orig
```

##### 3. Create a new sh configuration file

You can create a new sh config file by copying the template that we have included for you.

```shell
cp ~/.oh-my-bash/templates/bashrc.osh-template ~/.bashrc
```

##### 4. Reload your .bashrc

```shell
source ~/.bashrc
```

##### 5. Initialize your new bash configuration

Once you open up a new terminal window, it should load sh with Oh My Bash's configuration.

### Installation Problems

If you have any hiccups installing, here are a few common fixes.

* You _might_ need to modify your `PATH` in `~/.bashrc` if you're not able to find some commands after switching to `oh-my-bash`.
* If you installed manually or changed the install location, check the `OSH` environment variable in `~/.bashrc`.

### Customization of  Plugins and Themes

If you want to override any of the default behaviors, just add a new file (ending in `.sh`) in the `custom/` directory.

If you have many functions that go well together, you can put them as a `XYZ.plugin.sh` file in the `custom/plugins/` directory and then enable this plugin.

If you would like to modify an existing module (theme/plugin/aliases/completion) bundled with Oh My Bash, first copy the original module to `custom/` directory and modify it.  It will be loaded instead of the original one.

```bash
$ mkdir -p "$OSH_CUSTOM/themes"
$ cp -r {"$OSH","$OSH_CUSTOM"}/themes/agnoster
$ EDIT "$OSH_CUSTOM/themes/agnoster/agnoster.theme.sh"
```

If you would like to track the upstream changes for your customized version of modules, you can optionally directly edit the original files and commit them.  In this case, you need to handle possible conflicts with the upstream in upgrading.

If you would like to replace an existing module (theme/plugin/aliases/complet) bundled with Oh My Bash, create a module of the same name in the `custom/` directory so that it will be loaded instead of the original one.

### Configuration

#### Enable/disable python venv

The python virtualenv/condaenv information in the prompt may be enabled by the following line in `~/.bashrc`.

```bash
OMB_PROMPT_SHOW_PYTHON_VENV=true
```

Some themes turn on it by default.  If you would like to turn it off, you may disable it by the following line in `~/.bashrc`:

```bash
OMB_PROMPT_SHOW_PYTHON_VENV=false
```

#### Disable internal uses of `sudo`

Some plugins of oh-my-bash internally use `sudo` when it is necessary.  However, this might clutter with the `sudo` log.  To disable the use of `sudo` by oh-my-bash, `OMB_USE_SUDO` can be set to `false` in `~/.bashrc`.

```bash
OMB_USE_SUDO=false
```

Each plugin might provides finer configuration variables to control the use of `sudo` by each plugin.

## Getting Updates

By default, you will be prompted to check for upgrades every few weeks. If you would like `oh-my-bash` to automatically upgrade itself without prompting you, set the following in your `~/.bashrc`:

```shell
DISABLE_UPDATE_PROMPT=true
```

To disable automatic upgrades, set the following in your `~/.bashrc`:

```shell
DISABLE_AUTO_UPDATE=true
```

### Manual Updates

If you'd like to upgrade at any point in time (maybe someone just released a new plugin and you don't want to wait a week?) you just need to run:

```shell
upgrade_oh_my_bash
```

Magic!

## Uninstalling Oh My Bash

Oh My Bash isn't for everyone. We'll miss you, but we want to make this an easy breakup.

If you want to uninstall `oh-my-bash`, just run `uninstall_oh_my_bash` from the command-line. It will remove itself and revert your previous `bash` configuration.

## Contributing

I'm far from being a [Bash](https://www.gnu.org/software/bash/) expert and suspect there are many ways to improve – if you have ideas on how to make the configuration easier to maintain (and faster), don't hesitate to fork and send pull requests!

We also need people to test out pull-requests. So take a look through [the open issues](https://github.com/ohmybash/oh-my-bash/issues) and help where you can.

## Contributors

Oh My Bash has a vibrant community of happy users and delightful contributors. Without all the time and help from our contributors, it wouldn't be so awesome.

Thank you so much!

## License

Oh My Bash is derived from [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh).
Oh My Bash is released under the [MIT license](LICENSE.md).
