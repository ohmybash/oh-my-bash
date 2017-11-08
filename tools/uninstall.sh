#!/usr/bin/env bash

read -r -p "Are you sure you want to remove Oh My Bash? [y/N] " confirmation
if [ "$confirmation" != y ] && [ "$confirmation" != Y ]; then
  echo "Uninstall cancelled"
  exit
fi

echo "Removing ~/.oh-my-bash"
if [ -d $HOME/.oh-my-bash ]; then
  rm -rf $HOME/.oh-my-bash
fi

echo "Looking for original bash config..."
if [ -f $HOME/.bash_profile.pre-oh-my-bash ] || [ -h $HOME/.bash_profile.pre-oh-my-bash ]; then
  echo "Found ~/.bash_profile.pre-oh-my-bash -- Restoring to ~/.bash_profile";

  if [ -f $HOME/.bash_profile ] || [ -h $HOME/.bash_profile ]; then
    BASH_PROFILE_SAVE=".bash_profile.omb-uninstalled-$(date +%Y%m%d%H%M%S)";
    echo "Found ~/.bash_profile -- Renaming to ~/${BASH_PROFILE_SAVE}";
    mv $HOME/.bash_profile $HOME/"${BASH_PROFILE_SAVE}";
  fi

  mv $HOME/.bash_profile.pre-oh-my-bash $HOME/.bash_profile;

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
