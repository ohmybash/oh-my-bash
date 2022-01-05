#!/usr/bin/env bash

source $OSH/plugins/progress/progress2.plugin.sh

for i in {0..101}; do progress $i; done
