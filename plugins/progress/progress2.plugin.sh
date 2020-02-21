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

# source into your script. Call the progress function to update the ui.

_STEP_DELAY=0.1;
shopt -s checkwinsize; (:); #echo $LINES $COLUMNS

#
# Description : delay between steps
#
function delay
{
    sleep $_STEP_DELAY;
}

#
# Description : set the delay interval
function set_delay()
{
    $_STEP_DELAY=$1
}

#
# Description : print out executing progress
# 
_PCT_THEN=0
function progress()
{
    _PCT_NOW=$1;
    _PARAM_PHASE=$2;
    #TODO: find/use width of term
    if [ $_PCT_THEN -le 0 ] && [ $_PCT_NOW -ge 0 ]  ; then echo -ne "[..........................] (0%)  $PARAM_PHASE \r"  ; delay; fi;
    if [ $_PCT_THEN -le 90 ] && [ $_PCT_NOW -ge 90 ]; then echo -ne "[##########################] (100%) $PARAM_PHASE \r" ; delay; fi;
    if [ $_PCT_THEN -le 100 ] && [ $_PCT_NOW -ge 100 ];then echo -ne 'Done!                                            \n' ; delay; fi;

    _PCT_THEN=$_PCT_NOW;
}
