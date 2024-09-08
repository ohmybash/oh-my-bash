#! bash oh-my-bash.module
#
# This completion setting seems to originate from the following repository:
# https://github.com/tfmalt/bash-completion-virtualbox
#
# The license is unspecified.  The upstream is not active for nine years (as of
# 2024-08), so we would adjust the codes by ourselves.
#
# Change history
#
# * 2017-10-10 This file was added to Oh My Bash. This is probably taken from
#   the following version:
#   https://github.com/tfmalt/bash-completion-virtualbox/blob/fb9739cfe9d2a6d0076c5423dc25393bcf6a77dd/vboxmanage_completion.bash
# * 2024-08-13 The file cotnent is update to the latest upstream version based on:
#   https://github.com/tfmalt/bash-completion-virtualbox/blob/02df30e0b8e399b8011d95aa917caf0aafe01d27/vboxmanage_completion.bash
#
#------------------------------------------------------------------------------
#!/usr/bin/env bash
#
# Attempt at autocompletion script for vboxmanage. This scripts assumes an
# alias between VBoxManage and vboxmanaage.
#
# Copyright (c) 2012  Thomas Malt <thomas@malt.no>
#

#alias vboxmanage="VBoxManage"

complete -F _vboxmanage vboxmanage

# export VBOXMANAGE_NIC_TYPES

function _vboxmanage {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # _omb_util_print "cur: |$cur|"
  # _omb_util_print "prev: |$prev|"

  case $prev in
  -v|--version)
    return 0
    ;;

  -l|--long)
    opts=$(__vboxmanage_list "long")
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    return 0
    ;;
  --nic[1-8])
    # This is part of modifyvm subcommand
    opts=$(__vboxmanage_nic_types)
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    ;;
  startvm|list)
    opts=$(__vboxmanage_$prev)
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    return 0
    ;;
  --type)
    COMPREPLY=($(compgen -W "gui headless" -- ${cur}))
    return 0
    ;;
  gui|headless)
    # Done. no more completion possible
    return 0
    ;;
  vboxmanage)
    # In case current is complete command we return emmideatly.
    case $cur in
    startvm|list|controlvm|showvminfo|modifyvm)
      COMPREPLY=($(compgen -W "$cur "))
      return 0
      ;;
    esac

    # _omb_util_print "Got vboxmanage"
    opts=$(__vboxmanage_default)
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    return 0
    ;;
  -q|--nologo)
    opts=$(__vboxmanage_default)
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    return 0
    ;;
  controlvm|showvminfo|modifyvm)
    opts=$(__vboxmanage_list_vms)
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    return 0
    ;;
  vrde|setlinkstate*)
    # vrde is a complete subcommand of controlvm
    opts="on off"
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    return 0
    ;;
  esac

  for VM in $(__vboxmanage_list_vms); do
    if [ "$VM" == "$prev" ]; then
      pprev=${COMP_WORDS[COMP_CWORD-2]}
      # _omb_util_print "previous: $pprev"
      case $pprev in
      startvm)
        opts="--type"
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        return 0
        ;;
      controlvm)
        opts=$(__vboxmanage_controlvm $VM)
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        return 0;
        ;;
      showvminfo)
        opts="--details --machinereadable --log"
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        return 0;
        ;;
      modifyvm)
        opts=$(__vboxmanage_modifyvm)
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        return 0
        ;;
      esac
    fi
  done

  # _omb_util_print "Got to end withoug completion"
}

function _vboxmanage_realopts {
  _omb_util_print $(vboxmanage | grep -Eo "^\s{2}[a-z]+")
  _omb_util_print " "
}

function __vboxmanage_nic_types {
  _omb_util_print $(vboxmanage |
           grep ' nic<' |
           sed 's/.*nic<1-N> \([a-z\|]*\).*/\1/' | tr '|' ' ')
}

function __vboxmanage_startvm {
  RUNNING=$(vboxmanage list runningvms | cut -d' ' -f1 | tr -d '"')
  TOTAL=$(vboxmanage list vms | cut -d' ' -f1 | tr -d '"')

  AVAILABLE=""
  for VM in $TOTAL; do
    MATCH=0;
    for RUN in $RUNNING "x"; do
      if [ "$VM" == "$RUN" ]; then
        MATCH=1
      fi
    done
    (( $MATCH == 0 )) && AVAILABLE="$AVAILABLE $VM "
  done
  _omb_util_print $AVAILABLE
}

function __vboxmanage_list {
  INPUT=$(vboxmanage list | tr -s '[\[\]\|\n]' ' ' | cut -d' ' -f4-)

  PRUNED=""
  if [ "$1" == "long" ]; then
    for WORD in $INPUT; do
      [ "$WORD" == "-l" ] && continue;
      [ "$WORD" == "--long" ] && continue;

      PRUNED="$PRUNED $WORD"
    done
  else
    PRUNED=$INPUT
  fi

  _omb_util_print $PRUNED
}


function __vboxmanage_list_vms {
  VMS=""
  if [ "x$1" == "x" ]; then
    SEPARATOR=" "
  else
    SEPARATOR=$1
  fi

  for VM in $(vboxmanage list vms | cut -d' ' -f1 | tr -d '"'); do
    [ "$VMS" != "" ] && VMS="${VMS}${SEPARATOR}"
    VMS="${VMS}${VM}"
  done

  _omb_util_print $VMS
}

function __vboxmanage_list_runningvms {
  VMS=""
  if [ "$1" == "" ]; then
    SEPARATOR=" "
  else
    SEPARATOR=$1
  fi

  for VM in $(vboxmanage list runningvms | cut -d' ' -f1 | tr -d '"'); do
    [ "$VMS" != "" ] && VMS="${VMS}${SEPARATOR}"
    VMS="${VMS}${VM}"
  done

  _omb_util_print $VMS
}

function __vboxmanage_controlvm {
  _omb_util_print "pause resume reset poweroff savestate acpipowerbutton"
  _omb_util_print "acpisleepbutton keyboardputscancode guestmemoryballoon"
  _omb_util_print "gueststatisticsinterval usbattach usbdetach vrde vrdeport"
  _omb_util_print "vrdeproperty vrdevideochannelquality setvideomodehint"
  _omb_util_print "screenshotpng setcredentials teleport plugcpu unplugcpu"
  _omb_util_print "cpuexecutioncap"

  # setlinkstate<1-N>
  activenics=$(__vboxmanage_showvminfo_active_nics $1)
  for nic in $(_omb_util_print "${activenics}" | tr -d 'nic'); do
    _omb_util_print "setlinkstate${nic}"
  done

# nic<1-N> null|nat|bridged|intnet|hostonly|generic
#                                      [<devicename>] |
                          # nictrace<1-N> on|off
                          #   nictracefile<1-N> <filename>
                          #   nicproperty<1-N> name=[value]
                          #   natpf<1-N> [<rulename>],tcp|udp,[<hostip>],
                          #                 <hostport>,[<guestip>],<guestport>
                          #   natpf<1-N> delete <rulename>
}

function __vboxmanage_modifyvm {
  options=$(vboxmanage modifyvm | grep '\[--' | grep -v '\[--nic<' |
              sed 's/ *\[--\([a-z]*\).*/--\1/')
  # Exceptions
  for i in {1..8}; do
    options="$options --nic${i}"
  done
  _omb_util_print $options
}

function __vboxmanage_showvminfo_active_nics {
  nics=$(vboxmanage showvminfo $1 --machinereadable |
           awk '/^nic/ && ! /none/' |
           awk '{ split($1, names, "="); print names[1] }')
  _omb_util_print $nics
}

function __vboxmanage_default {
  realopts=$(_vboxmanage_realopts)
  opts=$realopts$(vboxmanage | grep -i vboxmanage | cut -d' ' -f2 | grep -v '\[' | sort | uniq)
  pruned=""

  # _omb_util_print ""
  # _omb_util_print "DEBUG: cur: $cur, prev: $prev"
  # _omb_util_print "DEBUG: default: |$p1|$p2|$p3|$p4|"
  case ${cur} in
  -*)
    _omb_util_print $opts
    # COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    return 0
    ;;
  esac;

  for WORD in $opts; do
    MATCH=0
    for OPT in ${COMP_WORDS[@]}; do
      # opts=$(_omb_util_print ${opts} | grep -v $OPT);
      if [ "$OPT" == "$WORD" ]; then
        MATCH=1
        break;
      fi
      if [ "$OPT" == "-v" ] && [ "$WORD" == "--version" ]; then
        MATCH=1
        break;
      fi
      if [ "$OPT" == "--version" ] && [ "$WORD" == "-v" ]; then
        MATCH=1
        break;
      fi
      if [ "$OPT" == "-q" ] && [ "$WORD" == "--nologo" ]; then
        MATCH=1
        break;
      fi
      if [ "$OPT" == "--nologo" ] && [ "$WORD" == "-q" ]; then
        MATCH=1
        break;
      fi
    done
    (( $MATCH == 1 )) && continue;
    pruned="$pruned $WORD"

  done

  # COMPREPLY=($(compgen -W "${pruned}" -- ${cur}))
  _omb_util_print $pruned
  return 0
}
