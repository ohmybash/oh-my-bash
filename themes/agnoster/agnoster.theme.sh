#! bash oh-my-bash.module
#------------------------------------------------------------------------------
# MIT License
#
# Copyright (c) 2012-2014 Isaac Wolkerstorfer (@agnoster) and contributors.
# Copyright (c) 2014 Kenny Root (@kruton).
# Copyright (c) 2017-2021 Erik Selberg and contributors (https://github.com/speedenator/agnoster-bash/contributors).
# Copyright (c) 2019-present Toan Nguyen and contributors (https://github.com/ohmybash/oh-my-bash/graphs/contributors).
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
# Remarks:
#
# * Copyright 2012-2014 Isaac Wolkerstorfer (@agnoster) and contributors.
#
#   The agnoster theme originates from @agnoster's Zsh theme [1].  The version
#   in OMB can be traced back to [1] (updates were stopped in 2014), but the
#   latest version of the Zsh theme is found in [2].
#
#   [1] https://gist.github.com/agnoster/3712874
#   [2] https://github.com/agnoster/agnoster-zsh-theme
#
#   The original theme does not seem to specify the license, so strictly
#   speaking, we are not explicitly allowed to modify and redistribute the
#   agnoster theme.  The MIT license is proposed [3], but no action has appeard
#   to that.
#
#   [3] https://github.com/agnoster/agnoster-zsh-theme/pull/152
#
# * Copyright 2014 Kenny Root (@kruton)
#
#   Then the theme was translated to Bash by @kruton [4].  The license does not
#   seem to be specified again.
#
#   [4] https://gist.github.com/kruton/8345450
#
# * Copyright 2017-2021 Erik Selberg (@speedenator)
#
#   Then @speedenator has updated the theme by @kruton [5].
#
#   [5] https://github.com/speedenator/agnoster-bash
#
#   At this time, the MIT license is specified.  However, @speedenator seem to
#   claim the copyright for the work from 2012, which is actually the copyright
#   infringement.  The user @speedenator seems to have started to contribute
#   only from 2017.
#
# * Copyright 2019-present Toan Nguyen (@nntoan) and contributors.
#
#   The theme is imported into OMB by PR #54 [6].
#
#   [6] https://github.com/ohmybash/oh-my-bash/pull/54.
#
#------------------------------------------------------------------------------
# vim: ft=bash ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for BASH
#
# (Converted from ZSH theme by Kenny Root)
# https://gist.github.com/kruton/8345450
#
# Updated & fixed by Erik Selberg erik@selberg.org 1/14/17
# Tested on MacOSX, Ubuntu, Amazon Linux
# Bash v3 and v4
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
# I recommend: https://github.com/powerline/fonts.git
# > git clone https://github.com/powerline/fonts.git fonts
# > cd fonts
# > install.sh

# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.

# Install:

# I recommend the following:
# $ cd home
# $ mkdir -p .bash/themes/agnoster-bash
# $ git clone https://github.com/speedenator/agnoster-bash.git .bash/themes/agnoster-bash

# then add the following to your .bashrc:

# export THEME=$HOME/.bash/themes/agnoster-bash/agnoster.bash
# if [[ -f $THEME ]]; then
#     export DEFAULT_USER=$(whoami)
#     source "$THEME"
# fi

#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

# Generally speaking, this script has limited support for right
# prompts (ala powerlevel9k on zsh), but it's pretty problematic in Bash.
# The general pattern is to write out the right prompt, hit \r, then
# write the left. This is problematic for the following reasons:
# - Doesn't properly resize dynamically when you resize the terminal
# - Changes to the prompt (like clearing and re-typing, super common) deletes the prompt
# - Getting the right alignment via columns / tput cols is pretty problematic (and is a bug in this version)
# - Bash prompt escapes (like \h or \w) don't get interpolated
#
# all in all, if you really, really want right-side prompts without a
# ton of work, recommend going to zsh for now. If you know how to fix this,
# would appreciate it!

# note: requires bash v4+... Mac users - you often have bash3.
# 'brew install bash' will set you free
PROMPT_DIRTRIM=${PROMPT_DIRTRIM:-2} # bash4 and above

######################################################################
## Configurations in Oh My Bash

OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:=true}

######################################################################
DEBUG=0
function debug {
  if [[ ${DEBUG} -ne 0 ]]; then
    >&2 echo -e "$@"
  fi
}

######################################################################
### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
CURRENT_RBG='NONE'
SEGMENT_SEPARATOR=''
RIGHT_SEPARATOR=''
LEFT_SUBSEG=''
RIGHT_SUBSEG=''

function text_effect {
  case "$1" in
  reset)      echo 0;;
  bold)       echo 1;;
  underline)  echo 4;;
  esac
}

# to add colors, see
# http://bitmote.com/index.php?post/2012/11/19/Using-ANSI-Color-Codes-to-Colorize-Your-Bash-Prompt-on-Linux
# under the "256 (8-bit) Colors" section, and follow the example for orange below
function fg_color {
  case "$1" in
  black)      echo 30;;
  red)        echo 31;;
  green)      echo 32;;
  yellow)     echo 33;;
  blue)       echo 34;;
  magenta)    echo 35;;
  cyan)       echo 36;;
  white)      echo 37;;
  orange)     echo 38\;5\;166;;
  esac
}

function bg_color {
  case "$1" in
  black)      echo 40;;
  red)        echo 41;;
  green)      echo 42;;
  yellow)     echo 43;;
  blue)       echo 44;;
  magenta)    echo 45;;
  cyan)       echo 46;;
  white)      echo 47;;
  orange)     echo 48\;5\;166;;
  esac;
}

# TIL: declare is global not local, so best use a different name
# for codes (mycodes) as otherwise it'll clobber the original.
# this changes from BASH v3 to BASH v4.
function ansi {
  local seq
  local -a mycodes=("${!1}")

  debug "ansi: ${!1} all: $* aka ${mycodes[@]}"

  seq=""
  local i
  for ((i = 0; i < ${#mycodes[@]}; i++)); do
    if [[ -n $seq ]]; then
      seq="${seq};"
    fi
    seq="${seq}${mycodes[$i]}"
  done
  debug "ansi debug:" '\\[\\033['${seq}'m\\]'
  echo -ne '\[\033['${seq}'m\]'
  # PR="$PR\[\033[${seq}m\]"
}

function ansi_single {
  echo -ne '\[\033['$1'm\]'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
function prompt_segment {
  local bg fg
  local -a codes

  debug "Prompting $1 $2 $3"

  # if commented out from kruton's original... I'm not clear
  # if it did anything, but it messed up things like
  # prompt_status - Erik 1/14/17

  #    if [[ -z $1 || ( -z $2 && $2 != default ) ]]; then
  codes=("${codes[@]}" $(text_effect reset))
  #    fi
  if [[ -n $1 ]]; then
    bg=$(bg_color $1)
    codes=("${codes[@]}" $bg)
    debug "Added $bg as background to codes"
  fi
  if [[ -n $2 ]]; then
    fg=$(fg_color $2)
    codes=("${codes[@]}" $fg)
    debug "Added $fg as foreground to codes"
  fi

  debug "Codes: "
  # local -p codes

  if [[ $CURRENT_BG != NONE && $1 != $CURRENT_BG ]]; then
    local -a intermediate=($(fg_color $CURRENT_BG) $(bg_color $1))
    debug "pre prompt " $(ansi intermediate[@])
    PR="$PR $(ansi intermediate[@])$SEGMENT_SEPARATOR"
    debug "post prompt " $(ansi codes[@])
    PR="$PR$(ansi codes[@]) "
  else
    debug "no current BG, codes are (${codes[*]})"
    PR="$PR$(ansi codes[@]) "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && PR="$PR$3"
}

# End the prompt, closing any open segments
function prompt_end {
  if [[ -n $CURRENT_BG ]]; then
    local -a codes=($(text_effect reset) $(fg_color $CURRENT_BG))
    PR="$PR $(ansi codes[@])$SEGMENT_SEPARATOR"
  fi
  local -a reset=($(text_effect reset))
  PR="$PR $(ansi reset[@])"
  CURRENT_BG=''
}

### virtualenv prompt
function prompt_virtualenv {
  # Exclude pyenv
  [[ $PYENV_VIRTUALENV_INIT == 1 ]] && _omb_util_binary_exists pyenv && return 0

  if [[ -d $VIRTUAL_ENV ]]; then
    # Python could output the version information in both stdout and
    # stderr (e.g. if using pyenv, the output goes to stderr).
    local VERSION_OUTPUT=$("$VIRTUAL_ENV"/bin/python --version 2>&1)

    # The last word of the output of `python --version`
    # corresponds to the version number.
    local VENV_VERSION=$(awk '{print $NF}' <<< "$VERSION_OUTPUT")

    prompt_segment cyan white "[v] $(basename "$VENV_VERSION")"
  fi
}

### pyenv prompt
function prompt_pyenv {
  if [[ $PYENV_VIRTUALENV_INIT == 1 ]] && _omb_util_binary_exists pyenv; then
    # Priority is shell > local > global
    # When pyenv shell is set, the environment variable $PYENV_VERSION is set with the value we want
    if [[ ! ${PYENV_VERSION-} ]]; then
      # If not set, fall back to pyenv local/global to get the version
      local PYENV_VERSION=$(pyenv local 2>/dev/null || pyenv global 2>/dev/null)
    fi
    # If it is not the system's python, then display additional info
    if [[ "$PYENV_VERSION" != "system" ]]; then
      # It's a pyenv virtualenv, get the version number
      if [[ -d $PYENV_VIRTUAL_ENV ]]; then
        local VERSION_OUTPUT=$("$PYENV_VIRTUAL_ENV"/bin/python --version 2>&1)
        local PYENV_VENV_VERSION=$(awk '{print $NF}' <<< "$VERSION_OUTPUT")
        prompt_segment cyan white "[$PYENV_VERSION] $(basename "$PYENV_VENV_VERSION")"
      else
        prompt_segment cyan white "$PYENV_VERSION"
      fi
    fi
  fi
}

### conda env prompt
function prompt_condaenv {
  if [[ -d $CONDA_PREFIX ]]; then
    if [[ ! $CONDA_PROMPT_MODIFIER ]]; then
      CONDA_PROMPT_MODIFIER=$(basename "$CONDA_PREFIX")
    fi
    local CONDA_PYTHON_VERSION=$("$CONDA_PREFIX"/bin/python -c 'import platform;print(platform.python_version())')
    prompt_segment cyan white "[c] $CONDA_PROMPT_MODIFIER $CONDA_PYTHON_VERSION"
  fi
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
function prompt_context {
  local user=$(whoami)

  if [[ $user != $DEFAULT_USER || -n $SSH_CLIENT ]]; then
    prompt_segment black default "$user@\h"
  fi
}

# prints history followed by HH:MM, useful for remembering what
# we did previously
function prompt_histdt {
  prompt_segment black default "\! [\A]"
}


function git_status_dirty {
  dirty=$(_omb_prompt_git status -s 2> /dev/null | tail -n 1)
  [[ -n $dirty ]] && echo " ●"
}

function git_stash_dirty {
  stash=$(_omb_prompt_git stash list 2> /dev/null | tail -n 1)
  [[ -n $stash ]] && echo " ⚑"
}

# Git: branch/detached head, dirty status
function prompt_git {
  local ref dirty
  if _omb_prompt_git rev-parse --is-inside-work-tree &>/dev/null; then
    ZSH_THEME_GIT_PROMPT_DIRTY='±'
    dirty=$(git_status_dirty)
    stash=$(git_stash_dirty)
    ref=$(_omb_prompt_git symbolic-ref HEAD 2> /dev/null) ||
      ref="➦ $(_omb_prompt_git describe --exact-match --tags HEAD 2> /dev/null)" ||
      ref="➦ $(_omb_prompt_git show-ref --head -s --abbrev | head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green black
    fi
    PR="$PR${ref/refs\/heads\// }$stash$dirty"
  fi
}

# Mercurial: clean, modified and uncomitted files
function prompt_hg {
  local rev st branch
  if hg id &>/dev/null; then
    if hg prompt &>/dev/null; then
      if [[ $(hg prompt "{status|unknown}") == '?' ]]; then
        # if files are not added
        prompt_segment red white
        st='±'
      elif [[ $(hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment yellow black
        st='±'
      else
        # if working copy is clean
        prompt_segment green black $CURRENT_FG
      fi
      PR="$PR$(hg prompt "☿ {rev}@{branch}") $st"
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(hg id -b 2>/dev/null)
      if hg st | grep -q "^\?"; then
        prompt_segment red white
        st='±'
      elif hg st | grep -q "^[MA]"; then
        prompt_segment yellow black
        st='±'
      else
        prompt_segment green black $CURRENT_FG
      fi
      PR="$PR☿ $rev@$branch $st"
    fi
  fi
}

# Dir: current working directory
function prompt_dir {
  prompt_segment blue black '\w'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
function prompt_status {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="$(ansi_single $(fg_color red))✘"
  [[ $UID -eq 0 ]] && symbols+="$(ansi_single $(fg_color yellow))⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="$(ansi_single $(fg_color cyan))⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

######################################################################
#
# experimental right prompt stuff
# requires setting prompt_foo to use PRIGHT vs PR
# doesn't quite work per above

function rightprompt {
  printf "%*s" $COLUMNS "$PRIGHT"
}

# quick right prompt I grabbed to test things.
function __command_rprompt {
  local times= n=$COLUMNS tz
  for tz in ZRH:Europe/Zurich PIT:US/Eastern \
                              MTV:US/Pacific TOK:Asia/Tokyo; do
    [ $n -gt 40 ] || break
    times="$times ${tz%%:*}\e[30;1m:\e[0;36;1m"
    times="$times$(TZ=${tz#*:} date +%H:%M)\e[0m"
    n=$(( $n - 10 ))
  done
  [ -z "$times" ] || printf "%${n}s$times\\r" ''
}

# this doesn't wrap code in \[ \]
function ansi_r {
  local seq
  local -a mycodes2=("${!1}")

  debug "ansi: ${!1} all: $* aka ${mycodes2[@]}"

  seq=""
  local i
  for ((i = 0; i < ${#mycodes2[@]}; i++)); do
    if [[ -n $seq ]]; then
      seq="${seq};"
    fi
    seq="${seq}${mycodes2[$i]}"
  done
  debug "ansi debug:" '\\[\\033['${seq}'m\\]'
  echo -ne '\033['${seq}'m'
  # PR="$PR\[\033[${seq}m\]"
}

# Begin a segment on the right
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
function prompt_right_segment {
  local bg fg
  local -a codes

  debug "Prompt right"
  debug "Prompting $1 $2 $3"

  # if commented out from kruton's original... I'm not clear
  # if it did anything, but it messed up things like
  # prompt_status - Erik 1/14/17

  #    if [[ -z $1 || ( -z $2 && $2 != default ) ]]; then
  codes=("${codes[@]}" $(text_effect reset))
  #    fi
  if [[ -n $1 ]]; then
    bg=$(bg_color $1)
    codes=("${codes[@]}" $bg)
    debug "Added $bg as background to codes"
  fi
  if [[ -n $2 ]]; then
    fg=$(fg_color $2)
    codes=("${codes[@]}" $fg)
    debug "Added $fg as foreground to codes"
  fi

  debug "Right Codes: "
  # local -p codes

  # right always has a separator
  # if [[ $CURRENT_RBG != NONE && $1 != $CURRENT_RBG ]]; then
  #     $CURRENT_RBG=
  # fi
  local -a intermediate2=($(fg_color $1) $(bg_color $CURRENT_RBG) )
  # PRIGHT="$PRIGHT---"
  debug "pre prompt " $(ansi_r intermediate2[@])
  PRIGHT="$PRIGHT$(ansi_r intermediate2[@])$RIGHT_SEPARATOR"
  debug "post prompt " $(ansi_r codes[@])
  PRIGHT="$PRIGHT$(ansi_r codes[@]) "
  # else
  #     debug "no current BG, codes are (${codes[*]})"
  #     PRIGHT="$PRIGHT$(ansi codes[@]) "
  # fi
  CURRENT_RBG=$1
  [[ -n $3 ]] && PRIGHT="$PRIGHT$3"
}

######################################################################
## Emacs prompt --- for dir tracking
# stick the following in your .emacs if you use this:

# (setq dirtrack-list '(".*DIR *\\([^ ]*\\) DIR" 1 nil))
# (defun dirtrack-filter-out-pwd-prompt (string)
#   "dirtrack-mode doesn't remove the PWD match from the prompt.  This does."
#   ;; TODO: support dirtrack-mode's multiline regexp.
#   (if (and (stringp string) (string-match (first dirtrack-list) string))
#       (replace-match "" t t string 0)
#     string))
# (add-hook 'shell-mode-hook
#           #'(lambda ()
#               (dirtrack-mode 1)
#               (add-hook 'comint-preoutput-filter-functions
#                         'dirtrack-filter-out-pwd-prompt t t)))

function prompt_emacsdir {
  # no color or other setting... this will be deleted per above
  PR="DIR \w DIR$PR"
}

######################################################################
## Main prompt

function build_prompt {
  [[ ! -z ${AG_EMACS_DIR+x} ]] && prompt_emacsdir
  prompt_status
  #[[ -z ${AG_NO_HIST+x} ]] && prompt_histdt
  [[ -z ${AG_NO_CONTEXT+x} ]] && prompt_context
  if [[ ${OMB_PROMPT_SHOW_PYTHON_VENV-} ]]; then
    prompt_virtualenv
    prompt_pyenv
    prompt_condaenv
  fi
  prompt_dir
  prompt_git
  prompt_hg
  prompt_end
}

# from orig...
# export PS1='$(ansi_single $(text_effect reset)) $(build_prompt) '
# this doesn't work... new model: create a prompt via a PR variable and
# use that.

function _omb_theme_PROMPT_COMMAND {
  local RETVAL=$?
  local PRIGHT=""
  local CURRENT_BG=NONE
  local PR="$(ansi_single $(text_effect reset))"
  build_prompt

  # uncomment below to use right prompt
  #     PS1='\[$(tput sc; printf "%*s" $COLUMNS "$PRIGHT"; tput rc)\]'$PR
  PS1=$PR
}
_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
