#!/usr/bin/env bash

EPOCHSECONDS="$(date +%s)"

function _current_epoch() {
  echo $(( $EPOCHSECONDS / 60 / 60 / 24 ))
}

function _update_osh_update() {
  echo "LAST_EPOCH=$(_current_epoch)" >| ~/.osh-update
}

function _upgrade_osh() {
  env BASH=$OSH sh $OSH/tools/upgrade.sh
  # update the osh file
  _update_osh_update
}

epoch_target=$UPDATE_OSH_DAYS
if [[ -z "$epoch_target" ]]; then
  # Default to old behavior
  epoch_target=13
fi

# Cancel upgrade if the current user doesn't have write permissions for the
# oh-my-bash directory.
[[ -w "$OSH" ]] || return 0

# Cancel upgrade if git is unavailable on the system
which git >/dev/null || return 0

if mkdir "$OSH/log/update.lock" 2>/dev/null; then
  if [ -f ~/.osh-update ]; then
    . ~/.osh-update

    if [[ -z "$LAST_EPOCH" ]]; then
      _update_osh_update && return 0;
    fi

    epoch_diff=$(($(_current_epoch) - $LAST_EPOCH))
    if [ $epoch_diff -gt $epoch_target ]; then
      if [ "$DISABLE_UPDATE_PROMPT" = "true" ]; then
        _upgrade_osh
      else
        echo "[Oh My Bash] Would you like to check for updates? [Y/n]: \c"
        read line
        if [[ "$line" == Y* ]] || [[ "$line" == y* ]] || [ -z "$line" ]; then
          _upgrade_osh
        else
          _update_osh_update
        fi
      fi
    fi
  else
    # create the osh file
    _update_osh_update
  fi

  rmdir $OSH/log/update.lock
fi
