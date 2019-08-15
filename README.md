Oh My Bash is an open source, community-driven framework for managing your [bash](https://www.gnu.org/software/bash/) configuration.

Sounds boring. Let's try again.

Oh My Bash will not make you a 10x developer...but you might feel like one.

Once installed, your terminal shell will become the talk of the town or your money back! With each keystroke in your command prompt, you'll take advantage of the hundreds of powerful plugins and beautiful themes. Strangers will come up to you in cafés and ask you, "that is amazing! are you some sort of genius?"

Finally, you'll begin to get the sort of attention that you have always felt you deserved. ...or maybe you'll use the time that you're saving to start flossing more often.

## Getting Started

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/11d90a2ad7bc4351a71a5dea523ec305)](https://app.codacy.com/app/Kreyren/oh-my-bash?utm_source=github.com&utm_medium=referral&utm_content=ohmybash/oh-my-bash&utm_campaign=Badge_Grade_Dashboard)

### Prerequisites

__Disclaimer:__ _Oh My Bash works best on macOS and Linux._

* Unix-like operating system (macOS or Linux)
* `curl` or `wget` should be installed
* `git` should be installed

### Basic Installation

Oh My Bash is installed by running one of the following commands in your terminal. You can install this via the command-line with either `curl` or `wget`.

#### via curl

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

#### via wget

```shell
sh -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
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

#### Using Plugins

Most plugins (should! we're working on this) include a __README__, which documents how to use them.

### Themes

We'll admit it. Early in the Oh My Bash world, we may have gotten a bit too theme happy. We have over one hundred themes now bundled. Most of them have [screenshots](https://github.com/ohmybash/oh-my-bash/wiki/Themes) on the wiki. Check them out!

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

## Advanced Topics

If you're the type that likes to get their hands dirty, these sections might resonate.

### Advanced Installation

Some users may want to change the default path, or manually install Oh My Bash.

#### Custom Directory

The default location is `~/.oh-my-bash` (hidden in your home directory)

If you'd like to change the install directory with the `OSH` environment variable, either by running `export OSH=/your/path` before installing, or by setting it before the end of the install pipeline like this:

```shell
export OSH="$HOME/.dotfiles/oh-my-bash"; sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

#### Manual Installation

##### 1. Clone the repository:

```shell
git clone git://github.com/ohmybash/oh-my-bash.git ~/.oh-my-bash
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

### Custom Plugins and Themes

If you want to override any of the default behaviors, just add a new file (ending in `.sh`) in the `custom/` directory.

If you have many functions that go well together, you can put them as a `XYZ.plugin.sh` file in the `custom/plugins/` directory and then enable this plugin.

If you would like to override the functionality of a plugin distributed with Oh My Bash, create a plugin of the same name in the `custom/plugins/` directory and it will be loaded instead of the one in `plugins/`.

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

Oh My Bash is released under the [WTFPL license](LICENSE.txt).
