#!/usr/bin/env bash

read -r -p "Are you sure you want to remove Oh My Bash? [y/N] " confirmation
if [ "$confirmation" != y ] && [ "$confirmation" != Y ]; then
  echo "Uninstall cancelled"
  exit
fi

echo "Removing ~/.oh-my-bash"
if [ -d ~/.oh-my-bash ]; then
  rm -rf ~/.oh-my-bash
fi

echo "Looking for original bash config..."
if [ -f ~/.bashrc.pre-oh-my-bash ] || [ -h ~/.bashrc.pre-oh-my-bash ]; then
  echo "Found ~/.bashrc.pre-oh-my-bash -- Restoring to ~/.bashrc";

  if [ -f ~/.bashrc ] || [ -h ~/.bashrc ]; then
    bashrc_SAVE=".bashrc.omb-uninstalled-$(date +%Y%m%d%H%M%S)";
    echo "Found ~/.bashrc -- Renaming to ~/${bashrc_SAVE}";
    mv ~/.bashrc ~/"${bashrc_SAVE}";
  fi

  mv ~/.bashrc.pre-oh-my-bash ~/.bashrc;
  exec bash; source ~/.bashrc

  echo "Your original bash config was restored. Please restart your session."
else
  if hash chsh >/dev/null 2>&1; then
    echo "Switching back to bash"
    chsh -s /bin/bash
  else
    echo "You can edit /etc/passwd to switch your default shell back to bash"
  fi
fi

echo "Thanks for trying out Oh My Bash. It has been uninstalled."
