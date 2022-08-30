#!/usr/bin/env bash

# Checks the minium version of bash (v3.2) installed,
# stops the installation if check fails
if [ -z "${BASH_VERSION-}" ]; then
  printf "Error: Bash 3.2 or higher is required for Oh My Bash.\n"
  printf "Error: Install Bash and try running this installation script with Bash.\n"
  if command -v bash >/dev/null 2>&1; then
    printf 'Example: \033[31;1mbash\033[0;34m -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"\n'
  fi
  return 1 >/dev/null 2>&1 || exit 1
fi

if [[ ! ${BASH_VERSINFO[0]-} ]] || ((BASH_VERSINFO[0] < 3 || BASH_VERSINFO[0] == 3 && BASH_VERSINFO[1] < 2)); then
  printf "Error: Bash 3.2 required for Oh My Bash.\n" >&2
  printf "Error: Upgrade Bash and try again.\n" >&2
  return 2 &>/dev/null || exit 2
elif ((BASH_VERSINFO[0] < 4)); then
  printf "Warning: Bash >=4 is no longer required for Oh My Bash but is cool to have ;)\n" >&2
  printf "Warning: Why don't you upgrade your Bash to 4 or higher?\n" >&2
fi

_omb_install_print_version() {
  local OMB_VERSINFO
  OMB_VERSINFO=(1 0 0 0 master noarch)
  printf '%s\n' 'Install script for Oh-My-Bash (https://github.com/ohmybash/oh-my-bash)'
  printf 'oh-my-bash, version %s.%s.%s(%s)-%s (%s)\n' "${OMB_VERSINFO[@]}"
}

_omb_install_print_usage() {
  printf '%s\n' \
    'usage: ./install.sh [--unattended | --dry-run | --help | --usage | --version]' \
    'usage: bash -c "$(< install.sh)" [--unattended | --dry-run | --help | --usage |' \
    '           --version]'
}

_omb_install_print_help() {
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
_omb_install_readargs() {
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

_omb_install_run() {
  if [[ :$install_opts: == *:dry-run:* ]]; then
    printf '%s\n' "$BOLD$GREEN[dryrun]$NORMAL $BOLD$*$NORMAL" >&5
  else
    printf '%s\n' "$BOLD\$ $*$NORMAL" >&5
    command "$@"
  fi
}

_omb_install_banner() {
  # MOTD message :)
  printf '%s' "$GREEN"
  printf '%s\n' \
    '         __                          __               __  ' \
    '  ____  / /_     ____ ___  __  __   / /_  ____ ______/ /_ ' \
    ' / __ \/ __ \   / __ `__ \/ / / /  / __ \/ __ `/ ___/ __ \' \
    '/ /_/ / / / /  / / / / / / /_/ /  / /_/ / /_/ (__  ) / / /' \
    '\____/_/ /_/  /_/ /_/ /_/\__, /  /_.___/\__,_/____/_/ /_/ ' \
    '                        /____/                            .... is now installed!'
  printf '%s' "$NORMAL"
}

## @fn _omb_install_user_bashrc
##   @var[in] install_opts
##   @var[in] OSH
_omb_install_user_bashrc() {
  printf "${BLUE}Looking for an existing bash config...${NORMAL}\n"
  if [[ -f ~/.bashrc || -h ~/.bashrc ]]; then
    local bashrc_backup=~/.bashrc.omb-backup-$(date +%Y%m%d%H%M%S)
    printf "${YELLOW}Found ~/.bashrc.${NORMAL} ${GREEN}Backing up to $bashrc_backup${NORMAL}\n"
    _omb_install_run mv ~/.bashrc "$bashrc_backup"
  fi

  printf "${BLUE}Using the Oh My Bash template file and adding it to ~/.bashrc${NORMAL}\n"
  _omb_install_run cp "$OSH"/templates/bashrc.osh-template ~/.bashrc
  sed "/^export OSH=/ c\\
export OSH=$OSH
  " ~/.bashrc >| ~/.bashrc.omb-temp
  _omb_install_run mv -f ~/.bashrc.omb-temp ~/.bashrc

  set +e
  _omb_install_banner
  printf '%s\n' "${GREEN}Please look over the ~/.bashrc file to select a theme, plugins, completions, aliases, and options${NORMAL}"
  printf "${BLUE}${BOLD}%s${NORMAL}\n" "To keep up on the latest news and updates, follow us on GitHub: https://github.com/ohmybash/oh-my-bash"

  if [[ :$install_opts: == *:dry-run:* ]]; then
    printf '%s\n' "$GREEN$BOLD[dryrun]$NORMAL Sample bashrc is created at '$BOLD$HOME/.bashrc-ombtemp$NORMAL'."
  elif [[ :$install_opts: != *:unattended:* ]]; then
    if [[ $- == *i* ]]; then
      # In case install.sh is sourced from the interactive Bash
      source ~/.bashrc
    else
      exec bash
    fi
  fi
}

_omb_install_system_bashrc() {
  printf "${BLUE}Creating a bashrc template at '$OSH/bashrc'...${NORMAL}\n"
  local q=\' Q="'\''"
  local osh="'${OSH//$q/$Q}'"
  osh=${osh//$'\n'/$'\\\n'}
  local sed_script='/^export OSH=.*/c \
'"export OSH=$osh"
  _omb_install_run sed "$sed_script" "$OSH"/templates/bashrc.osh-template >| "$OSH"/bashrc

  _omb_install_banner
  printf '%s\n' "${GREEN}To enable Oh My Bash, please copy '${BOLD}$OSH/bashrc${NORMAL}${GREEN}' to '${BOLD}~/.bashrc${NORMAL}${GREEN}'.${NORMAL}"
  printf '%s\n' "${GREEN}Please look over the ~/.bashrc file to select a theme, plugins, completions, aliases, and options${NORMAL}"
  printf "${BLUE}${BOLD}%s${NORMAL}\n" "To keep up on the latest news and updates, follow us on GitHub: https://github.com/ohmybash/oh-my-bash"
}

_omb_install_main() {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if type -P tput &>/dev/null; then
    local ncolors=$(tput colors 2>/dev/null || tput Co 2>/dev/null || echo -1)
  fi

  if [[ -t 1 && -n $ncolors && $ncolors -ge 8 ]]; then
    local RED=$(tput setaf 1 2>/dev/null || tput AF 1 2>/dev/null)
    local GREEN=$(tput setaf 2 2>/dev/null || tput AF 2 2>/dev/null)
    local YELLOW=$(tput setaf 3 2>/dev/null || tput AF 3 2>/dev/null)
    local BLUE=$(tput setaf 4 2>/dev/null || tput AF 4 2>/dev/null)
    local BOLD=$(tput bold 2>/dev/null || tput md 2>/dev/null)
    local NORMAL=$(tput sgr0 2>/dev/null || tput me 2>/dev/null)
  else
    local RED=""
    local GREEN=""
    local YELLOW=""
    local BLUE=""
    local BOLD=""
    local NORMAL=""
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

  printf "${BLUE}Cloning Oh My Bash...${NORMAL}\n"
  type -P git &>/dev/null || {
    echo "Error: git is not installed"
    return 1
  }
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [[ $OSTYPE = cygwin ]]; then
    if command git --version | command grep msysgit > /dev/null; then
      echo "Error: Windows/MSYS Git is not supported on Cygwin"
      echo "Error: Make sure the Cygwin git package is installed and is first on the path"
      return 1
    fi
  fi
  _omb_install_run git clone --depth=1 https://github.com/ohmybash/oh-my-bash.git "$OSH" || {
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
