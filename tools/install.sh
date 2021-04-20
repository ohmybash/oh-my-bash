#!/usr/bin/env bash

# Checks the minium version of bash (v4) installed, 
# stops the installation if check fails
if [ -z "$BASH_VERSION" ] || \
     { bash_major_version=$(echo "$BASH_VERSION" | cut -d '.' -f 1); 
       [ "${bash_major_version}" -lt "4" ]; }; then
  printf "Error: Bash 4 required for Oh My Bash.\n"
  printf "Error: Upgrade Bash and try again.\n"
  exit 1
fi

main() {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if hash tput >/dev/null 2>&1; then
    ncolors=$(tput colors 2>/dev/null || tput Co 2>/dev/null || echo -1)
  fi

  if [[ -t 1 && -n $ncolors && $ncolors -ge 8 ]]; then
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

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo
  set -e

  if [[ ! $OSH ]]; then
    OSH=~/.oh-my-bash
  fi

  if [[ -d $OSH ]]; then
    printf "${YELLOW}You already have Oh My Bash installed.${NORMAL}\n"
    printf "You'll need to remove $OSH if you want to re-install.\n"
    exit
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  printf "${BLUE}Cloning Oh My Bash...${NORMAL}\n"
  hash git >/dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [[ $OSTYPE = cygwin ]]; then
    if git --version | grep msysgit > /dev/null; then
      echo "Error: Windows/MSYS Git is not supported on Cygwin"
      echo "Error: Make sure the Cygwin git package is installed and is first on the path"
      exit 1
    fi
  fi
  env git clone --depth=1 https://github.com/ohmybash/oh-my-bash.git "$OSH" || {
    printf "Error: git clone of oh-my-bash repo failed\n"
    exit 1
  }

  printf "${BLUE}Looking for an existing bash config...${NORMAL}\n"
  if [[ -f ~/.bashrc || -h ~/.bashrc ]]; then
    printf "${YELLOW}Found ~/.bashrc.${NORMAL} ${GREEN}Backing up to ~/.bashrc.pre-oh-my-bash${NORMAL}\n";
    mv ~/.bashrc ~/.bashrc.pre-oh-my-bash;
  fi

  printf "${BLUE}Using the Oh My Bash template file and adding it to ~/.bashrc${NORMAL}\n"
  cp "$OSH"/templates/bashrc.osh-template ~/.bashrc
  sed "/^export OSH=/ c\\
export OSH=$OSH
  " ~/.bashrc > ~/.bashrc-ombtemp
  mv -f ~/.bashrc-ombtemp ~/.bashrc

  # MOTD message :)
  printf '%s' "$GREEN"
  printf '%s\n' '         __                          __               __  '
  printf '%s\n' '  ____  / /_     ____ ___  __  __   / /_  ____ ______/ /_ '
  printf '%s\n' ' / __ \/ __ \   / __ `__ \/ / / /  / __ \/ __ `/ ___/ __ \'
  printf '%s\n' '/ /_/ / / / /  / / / / / / /_/ /  / /_/ / /_/ (__  ) / / /'
  printf '%s\n' '\____/_/ /_/  /_/ /_/ /_/\__, /  /_.___/\__,_/____/_/ /_/ '
  printf '%s\n' '                        /____/                            .... is now installed!'
  printf "%s\n" "Please look over the ~/.bashrc file to select plugins, themes, and options"
  printf "${BLUE}${BOLD}%s${NORMAL}\n" "To keep up on the latest news and updates, follow us on GitHub: https://github.com/ohmybash/oh-my-bash"
  exec bash; source ~/.bashrc
}


main
