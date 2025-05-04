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

function _omb_theme_agnoster_text_effect {
  REPLY=
  case $1 in
  reset)     REPLY=0 ;;
  bold)      REPLY=1 ;;
  underline) REPLY=4 ;;
  esac
}

# to add colors, see
# http://bitmote.com/index.php?post/2012/11/19/Using-ANSI-Color-Codes-to-Colorize-Your-Bash-Prompt-on-Linux
# under the "256 (8-bit) Colors" section, and follow the example for orange below
function _omb_theme_agnoster_fg_color {
  REPLY=
  case $1 in
  black)   REPLY=30 ;;
  red)     REPLY=31 ;;
  green)   REPLY=32 ;;
  yellow)  REPLY=33 ;;
  blue)    REPLY=34 ;;
  magenta) REPLY=35 ;;
  cyan)    REPLY=36 ;;
  white)   REPLY=37 ;;
  orange)  REPLY='38;5;166' ;;
  esac
}

function _omb_theme_agnoster_bg_color {
  REPLY=
  case $1 in
  black)   REPLY=40 ;;
  red)     REPLY=41 ;;
  green)   REPLY=42 ;;
  yellow)  REPLY=43 ;;
  blue)    REPLY=44 ;;
  magenta) REPLY=45 ;;
  cyan)    REPLY=46 ;;
  white)   REPLY=47 ;;
  orange)  REPLY='48;5;166' ;;
  esac
}

# TIL: declare is global not local, so best use a different name
# for codes (mycodes) as otherwise it'll clobber the original.
# this changes from BASH v3 to BASH v4.
function _omb_theme_agnoster_ansi_r {
  # this doesn't wrap code in \[ \]
  local seq
  local -a mycodes=("${!1}")

  debug "ansi: ${!1} all: $* aka ${mycodes[@]}"

  seq=""
  local i
  for ((i = 0; i < ${#mycodes[@]}; i++)); do
    if [[ $seq ]]; then
      seq=$seq';'
    fi
    seq=$seq${mycodes[i]}
  done
  debug 'ansi debug: \\[\\033['"$seq"'m\\]'
  REPLY='\e['$seq'm'
}

function _omb_theme_agnoster_ansi {
  _omb_theme_agnoster_ansi_r "$@"
  REPLY='\['$REPLY'\]'
  # PR=$PR'\['$REPLY'\]'
}

function _omb_theme_agnoster_ansi_single {
  REPLY='\[\e['$1'm\]'
}

_omb_deprecate_defun_print 20000 text_effect _omb_theme_agnoster_text_effect
_omb_deprecate_defun_print 20000 fg_color _omb_theme_agnoster_fg_color
_omb_deprecate_defun_print 20000 bg_color _omb_theme_agnoster_bg_color
_omb_deprecate_defun_put 20000 ansi _omb_theme_agnoster_ansi
_omb_deprecate_defun_put 20000 ansi_r _omb_theme_agnoster_ansi_r
_omb_deprecate_defun_put 20000 ansi_single _omb_theme_agnoster_ansi_single

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
function prompt_segment {
  local REPLY
  local -a codes

  debug "Prompting $1 $2 $3"

  # > if commented out from kruton's original... I'm not clear if it did
  # > anything, but it messed up things like prompt_status - Erik 1/14/17
  #
  # I think ( -z $2 && $2 != default ) has been a mistake of ( $2 && $2 !=
  # default ) because ( -z $2 && $2 != default ) is equivalent to ( -z $2 ).  I
  # fixed it, so we may turn this on again, but I keep it inside the comment
  # because I'm not sure if there is any other side effect - Koichi 4/27/25
  #
  # See also the same code in the function "prompt_right_segment".
  #
  # if [[ ! $1 || ( $2 && $2 != default ) ]]; then
  _omb_theme_agnoster_text_effect reset
  [[ $REPLY ]] && codes+=("$REPLY")
  # fi
  if [[ $1 ]]; then
    _omb_theme_agnoster_bg_color "$1"
    [[ $REPLY ]] && codes+=("$REPLY")
    debug "Added $REPLY as background to codes"
  fi
  if [[ $2 ]]; then
    _omb_theme_agnoster_fg_color "$2"
    [[ $REPLY ]] && codes+=("$REPLY")
    debug "Added $REPLY as foreground to codes"
  fi

  debug "Codes: "
  # local -p codes

  if [[ $CURRENT_BG != NONE && $1 != $CURRENT_BG ]]; then
    local -a intermediate=()
    _omb_theme_agnoster_fg_color "$CURRENT_BG"
    [[ $REPLY ]] && intermediate+=("$REPLY")
    _omb_theme_agnoster_bg_color "$1"
    [[ $REPLY ]] && intermediate+=("$REPLY")
    _omb_theme_agnoster_ansi 'intermediate[@]'
    debug "pre prompt $REPLY"
    PR="$PR $REPLY$SEGMENT_SEPARATOR"
    _omb_theme_agnoster_ansi 'codes[@]'
    debug "post prompt $REPLY"
    PR="$PR$REPLY "
  else
    debug "no current BG, codes are (${codes[*]})"
    _omb_theme_agnoster_ansi 'codes[@]'
    PR="$PR$REPLY "
  fi
  CURRENT_BG=$1
  [[ $3 ]] && PR=$PR$3
}

# End the prompt, closing any open segments
function prompt_end {
  local REPLY
  if [[ $CURRENT_BG ]]; then
    local -a codes=()
    _omb_theme_agnoster_text_effect reset
    [[ $REPLY ]] && codes+=("$REPLY")
    _omb_theme_agnoster_fg_color "$CURRENT_BG"
    [[ $REPLY ]] && codes+=("$REPLY")
    _omb_theme_agnoster_ansi 'codes[@]'
    PR="$PR $REPLY$SEGMENT_SEPARATOR"
  fi
  _omb_theme_agnoster_text_effect reset
  local -a reset=(${REPLY:+"$REPLY"})
  _omb_theme_agnoster_ansi 'reset[@]'
  PR="$PR $REPLY"
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

    prompt_segment cyan white "[v] ${VIRTUAL_ENV_PROMPT:+$VIRTUAL_ENV_PROMPT }$(basename "$VENV_VERSION")"
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
  [[ $dirty ]] && _omb_util_print " ●"
}

function git_stash_dirty {
  stash=$(_omb_prompt_git stash list 2> /dev/null | tail -n 1)
  [[ $stash ]] && _omb_util_print " ⚑"
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
  local symbols REPLY
  symbols=()
  if ((RETVAL != 0)); then
    _omb_theme_agnoster_fg_color red
    _omb_theme_agnoster_ansi_single "$REPLY"
    symbols+=$REPLY'✘'
  fi
  if ((UID == 0)); then
    _omb_theme_agnoster_fg_color yellow
    _omb_theme_agnoster_ansi_single "$REPLY"
    symbols+=$REPLY'⚡'
  fi
  if compgen -j &>/dev/null; then
    _omb_theme_agnoster_fg_color cyan
    _omb_theme_agnoster_ansi_single "$REPLY"
    symbols+=$REPLY'⚙'
  fi

  [[ $symbols ]] && prompt_segment black default "$symbols"
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
    ((n > 40)) || break
    times="$times ${tz%%:*}\e[30;1m:\e[0;36;1m"
    times="$times$(TZ=${tz#*:} date +%H:%M)\e[0m"
    n=$((n - 10))
  done
  [[ ! $times ]] || printf '%*s%s\r' "$n" '' "$times"
}

# Begin a segment on the right
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
function prompt_right_segment {
  local REPLY
  local -a codes

  debug "Prompt right"
  debug "Prompting $1 $2 $3"

  # if [[ ! $1 || ( $2 && $2 != default ) ]]; then
  _omb_theme_agnoster_text_effect reset
  [[ $REPLY ]] && codes+=("$REPLY")
  # fi
  if [[ $1 ]]; then
    _omb_theme_agnoster_bg_color "$1"
    [[ $REPLY ]] && codes+=("$REPLY")
    debug "Added $REPLY as background to codes"
  fi
  if [[ $2 ]]; then
    _omb_theme_agnoster_fg_color "$2"
    [[ $REPLY ]] && codes+=("$REPLY")
    debug "Added $REPLY as foreground to codes"
  fi

  debug "Right Codes: "
  # local -p codes

  # right always has a separator
  # if [[ $CURRENT_RBG != NONE && $1 != $CURRENT_RBG ]]; then
  #     $CURRENT_RBG=
  # fi
  local -a intermediate2=()
  _omb_theme_agnoster_fg_color "$1"
  [[ $REPLY ]] && intermediate2+=("$REPLY")
  _omb_theme_agnoster_bg_color "$CURRENT_RBG"
  [[ $REPLY ]] && intermediate2+=("$REPLY")
  # PRIGHT="$PRIGHT---"
  _omb_theme_agnoster_ansi_r 'intermediate2[@]'
  debug "pre prompt $REPLY"
  PRIGHT="$PRIGHT$REPLY$RIGHT_SEPARATOR"
  _omb_theme_agnoster_ansi_r 'codes[@]'
  debug "post prompt $REPLY"
  PRIGHT="$PRIGHT$REPLY "
  # else
  #     debug "no current BG, codes are (${codes[*]})"
  #     _omb_theme_agnoster_ansi 'codes[@]'
  #     PRIGHT="$PRIGHT$REPLY "
  # fi
  CURRENT_RBG=$1
  [[ $3 ]] && PRIGHT=$PRIGHT$3
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
  local REPLY
  _omb_theme_agnoster_text_effect reset
  _omb_theme_agnoster_ansi_single "$REPLY"
  local PR=$REPLY
  build_prompt

  # uncomment below to use right prompt
  #     PS1='\[$(tput sc; printf "%*s" $COLUMNS "$PRIGHT"; tput rc)\]'$PR
  PS1=$PR
}
_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
