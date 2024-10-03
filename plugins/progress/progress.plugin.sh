#! bash oh-my-bash.module
############################---Description---###################################
#                                                                              #
# Summary       : Show a progress bar GUI on terminal platform                 #
# Support       : destro.nnt@gmail.com                                         #
# Created date  : Aug 12,2014                                                  #
# Latest Modified date : Aug 13,2014                                           #
#                                                                              #
################################################################################

############################---Usage---#########################################

# Copy below functions (delay and progress fuctions) into your shell script directly
# Then invoke progress function to show progress bar

# In other way, you could import source indirectly then using. Nothing different

################################################################################

# Global variable to store progress value
_omb_plugin_progress_value=0

#
# Description : delay executing script
#
function delay()
{
  sleep 0.2;
}

#
# Description : print out executing progress
#
function progress()
{
    local value=$1;
    local message=$2;

    if [ -z $value ]; then
      printf 'Usage: progress <value> [message]\n\n'
      printf 'Options:\n'
      printf '  value    The value for the progress bar. Use 0 to reset.\n'
      printf '  message  The optional message to display next to the progress bar.\n'
      return 2
    fi

    if [ $value -lt 0 ]; then
      _omb_log_error "invalid value: value' (expect: 0-100)" >&2
      return 2
    fi

    # Reset the progress value
    if [ $value -eq 0 ]; then
      _omb_plugin_progress_value=0;
      return 0
    fi

    # Get a clear line escape sequence
    local clear_line
    clear_line=$(tput el 2>/dev/null || tput ce 2>/dev/null)
    if [ -z $clear_line ]; then
      clear_line=$'\e[K'
    fi

    if [ $_omb_plugin_progress_value -le 0 -a $value -ge 0 ]  ; then printf "%s[....................] (0%%)  %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 5 -a $value -ge 5 ]  ; then printf "%s[#...................] (5%%)  %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 10 -a $value -ge 10 ]; then printf "%s[##..................] (10%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 15 -a $value -ge 15 ]; then printf "%s[###.................] (15%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 20 -a $value -ge 20 ]; then printf "%s[####................] (20%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 25 -a $value -ge 25 ]; then printf "%s[#####...............] (25%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 30 -a $value -ge 30 ]; then printf "%s[######..............] (30%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 35 -a $value -ge 35 ]; then printf "%s[#######.............] (35%%) %s\r" "$clear_line" "$message" ; delay; fi;

    if [ $_omb_plugin_progress_value -le 40 -a $value -ge 40 ]; then printf "%s[########............] (40%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 45 -a $value -ge 45 ]; then printf "%s[#########...........] (45%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 50 -a $value -ge 50 ]; then printf "%s[##########..........] (50%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 55 -a $value -ge 55 ]; then printf "%s[###########.........] (55%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 60 -a $value -ge 60 ]; then printf "%s[############........] (60%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 65 -a $value -ge 65 ]; then printf "%s[#############.......] (65%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 70 -a $value -ge 70 ]; then printf "%s[##############......] (70%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 75 -a $value -ge 75 ]; then printf "%s[###############.....] (75%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 80 -a $value -ge 80 ]; then printf "%s[################....] (80%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 85 -a $value -ge 85 ]; then printf "%s[#################...] (85%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 90 -a $value -ge 90 ]; then printf "%s[##################..] (90%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 95 -a $value -ge 95 ]; then printf "%s[###################.] (95%%) %s\r" "$clear_line" "$message" ; delay; fi;
    if [ $_omb_plugin_progress_value -le 100 -a $value -ge 100 ]; then
      # Display the finished progress bar, and then clear with a new line.
      printf "%s[####################] (100%%) %s\r" "$clear_line" "$message"
      delay
      printf "%s\n" "$clear_line"
      value=0
    fi;

    _omb_plugin_progress_value=$value;
}
