#!/usr/bin/env bash

if [ -f $HOME/.bashrc.pre-oh-my-bash ] || [ -h $HOME/.bashrc.pre-oh-my-bash ]; then
  mv $HOME/.bashrc.pre-oh-my-bash HOME/.bash_profile.pre-oh-my-bash
  cp $OSH/templates/bashrc.default-template $HOME/.bashrc
fi
