#!/usr/bin/env bash

# Copyright (c) 2020, F. Grant Robertson, https://github.com/grobertson/
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided
# that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice, this list of conditions
#       and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#       following disclaimer in the documentation and/or other materials provided with the distribution.
#     * Neither the name of F. Grant Robertson (aka @grobertson) nor the names of contributors
#       may be used to endorse or promote products derived from this software without
#       specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Intended to improve upon progress.plugin.sh by destro.nnt@gmail.com, Aug 13,2014. YMMV.

# USAGE:

# See README.md

#
# Description: Called automatically if _REMAIN_CHAR is unset
#   Call init_progress manually and then set your own values
#   to customize the display.
function init_progress {
    # Make $LINES $COLUMNS available using the builtin magic of shopt!
    shopt -s checkwinsize
    _STEP_DELAY=0.01
    _REMAIN_CHAR="."
    _COMPLETE_CHAR="#"
    _OPEN_GAUGE_CHAR='['
    _CLOSE_GAUGE_CHAR=']'
    _GAUGE_LABEL="Progress:"
    _OPEN_PCT_CHAR="("
    _CLOSE_PCT_CHAR=")"
    _PCT_THEN=0
}

#
# Description : Call with int {1..100} to display progress
function progress2() {
    # Set the initial vars if they haven't been set already.
    if ((${#_REMAIN_CHAR} == 0)); then init_progress; fi
    _PCT_NOW=$1
    # Stubbornly refusing to go backwards. BUT redraw if equal to the last draw anyway
    #   this could be handy if triggering a call to progress on window resize
    if ((_PCT_NOW > _PCT_THEN)); then
        if ((_PCT_NOW >= 100)); then
            #blank the line before \returning to pos 1 to print "Done!"
            printf %${COLUMNS}s
            echo -e "\rDone!"
        else
            #Recompute everything every time because the shopt will update $COLUMNS
            #   when the term size changes, and the progress bar will adjust itself!
            _FIELD_COLS=$((COLUMNS - (${#_GAUGE_LABEL} + ${#_OPEN_GAUGE_CHAR} + ${#_CLOSE_GAUGE_CHAR} + ${#_OPEN_PCT_CHAR} + ${#_CLOSE_PCT_CHAR} + 4)))
            # Bash doesn't 'do' floating point math and using "bc" is cheating
            _LEFT_COUNT=$((_FIELD_COLS * _PCT_NOW / 100))
            _RIGHT_COUNT=$((_FIELD_COLS - _LEFT_COUNT))
            _COMPLETE=$(printf %${_LEFT_COUNT}s | tr " " $_COMPLETE_CHAR)
            _REMAIN=$(printf %${_RIGHT_COUNT}s | tr " " $_REMAIN_CHAR)
            echo -ne "$_GAUGE_LABEL$_OPEN_GAUGE_CHAR$_COMPLETE$_REMAIN$_CLOSE_GAUGE_CHAR $_OPEN_PCT_CHAR$_PCT_NOW%$_CLOSE_PCT_CHAR\r"
            sleep $_STEP_DELAY
        fi
    fi
    _PCT_THEN=$_PCT_NOW
}
