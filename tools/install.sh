#!/usr/bin/env bash

# Checks the minium version of bash (v3.2) installed,
# stops the installation if check fails
if [ -z "${BASH_VERSION-}" ]; then
  printf "Error: Bash 3.2 or higher is required for Oh My Bash.\n"
  printf "Error: Install Bash and try running this installation script with Bash.\n"
  if command -v bash >/dev/null 2>&1; then
    # shellcheck disable=SC2016
    printf 'Example: \033[31;1mbash\033[0;34m -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"\n'
  fi
  # shellcheck disable=SC2317
  return 1 >/dev/null 2>&1 || exit 1
fi

if [[ ! ${BASH_VERSINFO[0]-} ]] || ((BASH_VERSINFO[0] < 3 || BASH_VERSINFO[0] == 3 && BASH_VERSINFO[1] < 2)); then
  printf "Error: Bash 3.2 required for Oh My Bash.\n" >&2
  printf "Error: Upgrade Bash and try again.\n" >&2
  # shellcheck disable=SC2317
  return 2 &>/dev/null || exit 2
elif ((BASH_VERSINFO[0] < 4)); then
  printf "Warning: Bash >=4 is no longer required for Oh My Bash but is cool to have ;)\n" >&2
  printf "Warning: Why don't you upgrade your Bash to 4 or higher?\n" >&2
fi

function _omb_install_print_version {
  local OMB_VERSINFO
  OMB_VERSINFO=(1 0 0 0 master noarch)
  printf '%s\n' 'Install script for Oh-My-Bash (https://github.com/ohmybash/oh-my-bash)'
  printf 'oh-my-bash, version %s.%s.%s(%s)-%s (%s)\n' "${OMB_VERSINFO[@]}"
}

function _omb_install_print_usage {
  # shellcheck disable=SC2016
  printf '%s\n' \
    'usage: ./install.sh [--unattended | --dry-run | --help | --usage | --version]' \
    'usage: bash -c "$(< install.sh)" [--unattended | --dry-run | --help | --usage |' \
    '           --version]'
}

function _omb_install_print_help {
  _omb_install_print_version
  _omb_install_print_usage
  printf '%s\n' \
    '' \
    'OPTIONS' \
    '  --help            show this help' \
    '  --version         show version' \
    '  --usage           show usage' \
    '  --dry-run         do not perform the actual installation' \
    '  --unattended      do not fall in to the new Bash session after the install' \
    '  --prefix=PATH     install oh-my-bash into "PATH/share/oh-my-bash"' \
    ''
}

## @fn _omb_install_readargs [options...]
##   @var[out] install_opts
##   @var[out] install_prefix
function _omb_install_readargs {
  install_opts=
  install_prefix=
  while (($#)); do
    local arg=$1; shift
    if [[ :$install_opts: != *:literal:* ]]; then
      case $arg in
      --prefix=*)
        arg=${arg#*=}
        if [[ $arg ]]; then
          install_prefix=$arg
        else
          install_opts+=:error
          printf 'install (oh-my-bash): %s\n' "$RED$BOLD[Error]$NORMAL ${RED}the option argument for '--prefix' is empty.$NORMAL" >&2
        fi
        continue ;;
      --prefix)
        if (($#)); then
          install_prefix=$1; shift
        else
          install_opts+=:error
          printf 'install (oh-my-bash): %s\n' "$RED$BOLD[Error]$NORMAL ${RED}an option argument for '$arg' is missing.$NORMAL" >&2
        fi
        continue ;;
      --help | --usage | --unattended | --dry-run)
        install_opts+=:${arg#--}
        continue ;;
      --version | -v)
        install_opts+=:version
        continue ;;
      --)
        install_opts+=:literal
        continue ;;
      -*)
        install_opts+=:error
        if [[ $arg == -[!-]?* ]]; then
          printf 'install (oh-my-bash): %s\n' "$RED$BOLD[Error]$NORMAL ${RED}unrecognized options '$arg'.$NORMAL" >&2
        else
          printf 'install (oh-my-bash): %s\n' "$RED$BOLD[Error]$NORMAL ${RED}unrecognized option '$arg'.$NORMAL" >&2
        fi
        continue ;;
      esac
    fi

    install_opts+=:error
    printf 'install (oh-my-bash): %s\n' "$RED$BOLD[Error]$NORMAL unrecognized argument '$arg'." >&2
  done
}

function _omb_install_run {
  if [[ :$install_opts: == *:dry-run:* ]]; then
    printf '%s\n' "$BOLD$GREEN[dryrun]$NORMAL $BOLD$*$NORMAL" >&5
  else
    printf '%s\n' "$BOLD\$ $*$NORMAL" >&5
    command "$@"
  fi
}

function _omb_install_banner {
  # MOTD message :)
  printf '%s' "$GREEN"
  # shellcheck disable=SC1003,SC2016
  printf '%s\n' \
    '         __                          __               __  ' \
    '  ____  / /_     ____ ___  __  __   / /_  ____ ______/ /_ ' \
    ' / __ \/ __ \   / __ `__ \/ / / /  / __ \/ __ `/ ___/ __ \' \
    '/ /_/ / / / /  / / / / / / /_/ /  / /_/ / /_/ (__  ) / / /' \
    '\____/_/ /_/  /_/ /_/ /_/\__, /  /_.___/\__,_/____/_/ /_/ ' \
    '                        /____/                            .... is now installed!'
  printf '%s' "$NORMAL"
}

function _omb_install_has_proper_bash_profile {
  if [[ -s ~/.bash_profile ]]; then
    if command grep -qE '(source|\.)[[:space:]].*/\.bashrc' ~/.bash_profile 2>/dev/null; then
      return 0
    fi
  fi

  if [[ -s ~/.profile ]]; then
    if command grep -qE '(source|\.)[[:space:]].*/\.bashrc' ~/.profile 2>/dev/null; then
      return 0
    fi
  fi

  return 1
}

## @fn _omb_install_user_bashrc
##   @var[in] install_opts
##   @var[in] OSH
function _omb_install_user_bashrc {
  printf '%s\n' "${BLUE}Looking for an existing bash config...${NORMAL}"
  if [[ -f ~/.bashrc || -h ~/.bashrc ]]; then
    # shellcheck disable=SC2155
    local bashrc_backup=~/.bashrc.omb-backup-$(date +%Y%m%d%H%M%S)
    printf '%s\n' "${YELLOW}Found ~/.bashrc.${NORMAL} ${GREEN}Backing up to $bashrc_backup${NORMAL}"
    _omb_install_run mv ~/.bashrc "$bashrc_backup"
  fi

  printf '%s\n' "${BLUE}Copying the Oh-My-Bash template file to ~/.bashrc${NORMAL}"
  sed "/^export OSH=/ c\\
export OSH='${OSH//\'/\'\\\'\'}'
  " "$OSH"/templates/bashrc.osh-template >| ~/.bashrc.omb-temp &&
    _omb_install_run mv -f ~/.bashrc.omb-temp ~/.bashrc

  # If "source ~/.bashrc" is not found in ~/.bash_profile or ~/.profile, we try
  # to create a new ~/.bash_profile with the default content or show messages
  # for user to add "source ~/.bashrc" in the existing ~/.bash_profile.
  if ! _omb_install_has_proper_bash_profile; then
    if [[ ! -e ~/.bash_profile ]]; then
      if [[ -h ~/.bash_profile ]]; then
        _omb_install_run rm -f ~/.bash_profile
      fi
      _omb_install_run cp -f "$OSH"/templates/bash_profile.osh-template ~/.bash_profile
    else
      printf '%s\n' "${GREEN}Please make sure that ~/.bash_profile contains \"source ~/.bashrc\"${NORMAL}"
    fi
  fi

  set +e
  _omb_install_banner
  printf '%s\n' "${GREEN}Please look over the ~/.bashrc file to select a theme, plugins, completions, aliases, and options${NORMAL}"
  printf '%s\n' "${BLUE}${BOLD}To keep up on the latest news and updates, follow us on GitHub: https://github.com/ohmybash/oh-my-bash${NORMAL}"

  if [[ :$install_opts: == *:dry-run:* ]]; then
    printf '%s\n' "$GREEN$BOLD[dryrun]$NORMAL Sample bashrc is created at '$BOLD$HOME/.bashrc-ombtemp$NORMAL'."
  elif [[ :$install_opts: != *:unattended:* ]]; then
    if [[ $- == *i* ]]; then
      # In case install.sh is sourced from the interactive Bash
      # shellcheck disable=SC1090
      source ~/.bashrc
    else
      exec bash
    fi
  fi
}

function _omb_install_system_bashrc {
  printf '%s\n' "${BLUE}Creating a bashrc template at '$OSH/bashrc'...${NORMAL}"
  local q=\' Q="'\''"
  local osh="'${OSH//$q/$Q}'"
  osh=${osh//$'\n'/$'\\\n'}
  local sed_script='/^export OSH=.*/c \
'"export OSH=$osh"
  _omb_install_run sed "$sed_script" "$OSH"/templates/bashrc.osh-template >| "$OSH"/bashrc

  _omb_install_banner
  printf '%s\n' "${GREEN}To enable Oh My Bash, please copy '${BOLD}$OSH/bashrc${NORMAL}${GREEN}' to '${BOLD}~/.bashrc${NORMAL}${GREEN}'.${NORMAL}"
  printf '%s\n' "${GREEN}Please look over the ~/.bashrc file to select a theme, plugins, completions, aliases, and options${NORMAL}"
  printf '%s\n' "${BLUE}${BOLD}To keep up on the latest news and updates, follow us on GitHub: https://github.com/ohmybash/oh-my-bash${NORMAL}"
}

function _omb_install_main {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  local ncolors=
  if type -P tput &>/dev/null; then
    ncolors=$(tput colors 2>/dev/null || tput Co 2>/dev/null || echo -1)
  fi

  local RED GREEN YELLOW BLUE BOLD NORMAL
  if [[ -t 1 && $ncolors && $ncolors -ge 8 ]]; then
    RED=$(tput setaf 1 2>/dev/null || tput AF 1 2>/dev/null)
    GREEN=$(tput setaf 2 2>/dev/null || tput AF 2 2>/dev/null)
    YELLOW=$(tput setaf 3 2>/dev/null || tput AF 3 2>/dev/null)
    BLUE=$(tput setaf 4 2>/dev/null || tput AF 4 2>/dev/null)
    BOLD=$(tput bold 2>/dev/null || tput md 2>/dev/null)
    NORMAL=$(tput sgr0 2>/dev/null || tput me 2>/dev/null)
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

  local install_opts install_prefix
  _omb_install_readargs "$@"

  if [[ :$install_opts: == *:error:* ]]; then
    printf '\n'
    install_opts+=:usage
  fi
  if [[ :$install_opts: == *:help:* ]]; then
    _omb_install_print_help
    install_opts+=:exit
  else
    if [[ :$install_opts: == *:version:* ]]; then
      _omb_install_print_version
      install_opts+=:exit
    fi
    if [[ :$install_opts: == *:usage:* ]]; then
      _omb_install_print_usage
      install_opts+=:exit
    fi
  fi
  if [[ :$install_opts: == *:error:* ]]; then
    return 2
  elif [[ :$install_opts: == *:exit:* ]]; then
    return 0
  fi

  if [[ $install_prefix ]]; then
    [[ $install_prefix == /* ]] ||
      install_prefix=$PWD/$install_prefix
    local OSH=$install_prefix/share/oh-my-bash
  elif [[ ! $OSH ]]; then
    OSH=~/.oh-my-bash
  fi

  if [[ ! $OSH_REPOSITORY ]]; then
    OSH_REPOSITORY=https://github.com/ohmybash/oh-my-bash.git
  fi

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo

  set -e

  if [[ -d $OSH ]]; then
    printf '%s\n' "${YELLOW}You already have Oh My Bash installed.${NORMAL}" >&2
    printf '%s\n' "You'll need to remove '$OSH' if you want to re-install it." >&2
    return 1
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  printf '%s\n' "${BLUE}Cloning Oh My Bash...${NORMAL}"
  type -P git &>/dev/null || {
    echo "Error: git is not installed"
    return 1
  }
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [[ $OSTYPE == cygwin ]]; then
    if command git --version | command grep msysgit > /dev/null; then
      echo "Error: Windows/MSYS Git is not supported on Cygwin"
      echo "Error: Make sure the Cygwin git package is installed and is first on the path"
      return 1
    fi
  fi
  _omb_install_run git clone --depth=1 "$OSH_REPOSITORY" "$OSH" || {
    printf "Error: git clone of oh-my-bash repo failed\n"
    return 1
  }

  if [[ $install_prefix ]]; then
    _omb_install_system_bashrc
  else
    _omb_install_user_bashrc
  fi
}

[[ ${BASH_EXECUTION_STRING-} && $0 == -* ]] &&
  set -- "$0" "$@"

_omb_install_main "$@" 5>&2
