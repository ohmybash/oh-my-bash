#! bash oh-my-bash.module
#
# The current version is based on the following upstream version:
# https://github.com/hashicorp/vagrant/blob/9df95a200280219ae5899db6eaa2e0eff4ad1a8e/contrib/bash/completion.sh
#------------------------------------------------------------------------------
# (The MIT License)
#
# Copyright (c) 2014 Kura
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


function __pwdln {
  pwdmod=$PWD/
  itr=0
  until [[ ! $pwdmod ]]; do
    ((itr++))
    pwdmod="${pwdmod#*/}"
  done
  _omb_util_put $((itr-1))
}

function __vagrantinvestigate {
  if [[ -f $PWD/.vagrant || -d $PWD/.vagrant ]]; then
    _omb_util_print "$PWD/.vagrant"
    return 0
  else
    pwdmod2=$PWD
    for ((i = 2; i <= $(__pwdln); i++)); do
      pwdmod2=${pwdmod2%/*}
      if [[ -f $pwdmod2/.vagrant || -d $pwdmod2/.vagrant ]]; then
        _omb_util_print "$pwdmod2/.vagrant"
        return 0
      fi
    done
  fi
  return 1
}

function _vagrant {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local prev=${COMP_WORDS[COMP_CWORD-1]}
  commands="box cloud connect destroy docker-exec docker-logs docker-run global-status halt help init list-commands login package plugin provision push rdp reload resume rsync rsync-auto share snapshot ssh ssh-config status suspend up version"

  if ((COMP_CWORD == 1)); then
    COMPREPLY=($(compgen -W "$commands" -- "$cur"))
    return 0
  fi

  if ((COMP_CWORD == 2)); then
    case $prev in
    "init")
      local box_list=$(find "${VAGRANT_HOME:-$HOME/.vagrant.d}/boxes" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sed -e 's/-VAGRANTSLASH-/\//')
      COMPREPLY=($(compgen -W "$box_list" -- "$cur"))
      return 0
      ;;
    "up")
      vagrant_state_file=$(__vagrantinvestigate) || return 1
      if [[ -d $vagrant_state_file ]]; then
        local vm_list=$(find "$vagrant_state_file/machines" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
      fi
      local up_commands="\
        --provision \
        --no-provision \
        --provision-with \
        --destroy-on-error \
        --no-destroy-on-error \
        --parallel \
        --no-parallel
        --provider \
        --install-provider \
        --no-install-provider \
        -h \
        --help"
      COMPREPLY=($(compgen -W "$up_commands $vm_list" -- "$cur"))
      return 0
      ;;
    "destroy"|"ssh"|"provision"|"reload"|"halt"|"suspend"|"resume"|"ssh-config")
      vagrant_state_file=$(__vagrantinvestigate) || return 1
      if [[ -f $vagrant_state_file ]]
      then
        running_vm_list=$(grep 'active' "$vagrant_state_file" | sed -e 's/"active"://' | tr ',' '\n' | cut -d '"' -f 2 | tr '\n' ' ')
      else
        running_vm_list=$(find "$vagrant_state_file/machines" -type f -name "id" | awk -F"/" '{print $(NF-2)}')
      fi
      COMPREPLY=($(compgen -W "$running_vm_list" -- "$cur"))
      return 0
      ;;
    "box")
      box_commands="add help list outdated prune remove repackage update"
      COMPREPLY=($(compgen -W "$box_commands" -- "$cur"))
      return 0
      ;;
    "cloud")
      cloud_commands="auth box search provider publish version"
      COMPREPLY=($(compgen -W "$cloud_commands" -- "$cur"))
      return 0
      ;;
    "plugin")
      plugin_commands="install license list uninstall update"
      COMPREPLY=($(compgen -W "$plugin_commands" -- "$cur"))
      return 0
      ;;
    "help")
      COMPREPLY=($(compgen -W "$commands" -- "$cur"))
      return 0
      ;;
    "snapshot")
      snapshot_commands="delete list pop push restore save"
      COMPREPLY=($(compgen -W "$snapshot_commands" -- "$cur"))
      return 0
      ;;
    *)
      ;;
    esac
  fi

  if ((COMP_CWORD == 3)); then
    action=${COMP_WORDS[COMP_CWORD-2]}
    case $action in
    "up")
      if [[ $prev == --no-provision ]]; then
        if [[ -d $vagrant_state_file ]]; then
          local vm_list=$(find "$vagrant_state_file/machines" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
        fi
        COMPREPLY=($(compgen -W "$vm_list" -- "$cur"))
        return 0
      fi
      ;;
    "box")
      case $prev in
      "remove"|"repackage")
        local box_list=$(find "${VAGRANT_HOME:-$HOME/.vagrant.d}/boxes" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sed -e 's/-VAGRANTSLASH-/\//')
        COMPREPLY=($(compgen -W "$box_list" -- "$cur"))
        return 0
        ;;
      "add")
        local add_commands="\
          --name \
          --checksum \
          --checksum-type \
          -c --clean \
          -f --force \
          "
        if [[ $cur == -* ]]; then
          COMPREPLY=($(compgen -W "$add_commands" -- "$cur"))
        else
          COMPREPLY=($(compgen -o default -- "$cur"))
        fi
        return 0
        ;;
      *)
        ;;
      esac
      ;;
    "snapshot")
      case $prev in
      "restore"|"delete")
        local snapshot_list=$(vagrant snapshot list)
        COMPREPLY=($(compgen -W "$snapshot_list" -- "$cur"))
        return 0
        ;;
      esac
      ;;
    *)
      ;;
    esac
  fi
}
complete -F _vagrant vagrant
