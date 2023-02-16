# agnoster

In order for this theme to render correctly, you will need a
[Powerline-patched font](https://gist.github.com/1595572).
I recommend: https://github.com/powerline/fonts.git
```
git clone https://github.com/powerline/fonts.git fonts
cd fonts
sh install.sh
```

The aim of this theme is to only show you *relevant* information. Like most
prompts, it will only show git information when in a git working directory.
However, it goes a step further: everything from the current user and
hostname to whether the last call exited with an error to whether background
jobs are running in this shell will all be displayed automatically when
appropriate.

Generally speaking, this script has limited support for right
prompts (ala powerlevel9k on zsh), but it's pretty problematic in Bash.
The general pattern is to write out the right prompt, hit \r, then
write the left. This is problematic for the following reasons:
- Doesn't properly resize dynamically when you resize the terminal
- Changes to the prompt (like clearing and re-typing, super common) deletes the prompt
- Getting the right alignment via columns / tput cols is pretty problematic (and is a bug in this version)
- Bash prompt escapes (like \h or \w) don't get interpolated

all in all, if you really, really want right-side prompts without a
ton of work, recommend going to zsh for now. If you know how to fix this,
would appreciate it!

![ScreenShot](agnoster-bash-sshot.png)

The direct upstream of the theme is [agnoster-bash](https://github.com/speedenator/agnoster-bash).
The current base is [`1165d1b3`](https://github.com/speedenator/agnoster-bash/commit/1165d1b3f125f52e7d4df953166d3c62774638fc).
New updates in the upstream can be found [here](https://github.com/speedenator/agnoster-bash/compare/1165d1b3f125f52e7d4df953166d3c62774638fc...master).
