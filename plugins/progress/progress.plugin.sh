#! bash oh-my-bash.module
############################---Description---###################################
#                                                                              #
# Summary       : Show a progress bar GUI on terminal platform                 #
# Support       : destro.nnt@gmail.com                                         #
# Created date  : Aug 12,2014                                                  #
# Latest Modified date : Dec 19,2024                                           #
#                                                                              #
################################################################################

############################---Usage---#########################################

# Copy below functions (delay and progress fuctions) into your shell script directly
# Then invoke progress function to show progress bar

# In other way, you could import source indirectly then using. Nothing different

################################################################################

# Global variable to store progress value
_omb_plugin_progress_value=0

_omb_plugin_progress_clear_line=

#
# Description : delay executing script
#
function delay {
  sleep 0.2
}

#
# Description : print out executing progress
#
function progress {
  local value=$1
  local message=$2

  if [[ ! $value ]]; then
    _omb_util_print_lines \
      'Usage: progress <value> [message]' \
      '' \
      'Options:' \
      '  value    The value for the progress bar. Use 0 to reset.' \
      '  message  The optional message to display next to the progress bar.'
    return 2
  fi

  if ((value < 0)); then
    _omb_log_error "invalid value: value' (expect: 0-100)" >&2
    return 2
  fi

  # Reset the progress value
  if ((value == 0)); then
    _omb_plugin_progress_value=0
    return 0
  fi

  # Get a clear line escape sequence
  local clear_line=$_omb_plugin_progress_clear_line
  if [[ ! $clear_line ]]; then
    clear_line=$(tput el 2>/dev/null || tput ce 2>/dev/null)
    if [[ ! $clear_line ]]; then
      clear_line=$'\e[K'
    fi
    _omb_plugin_progress_clear_line=$clear_line
  fi

  if ((_omb_plugin_progress_value <=   0 && value >=   0)); then printf "%s[............................] (0%%)  %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=   5 && value >=   5)); then printf "%s[#...........................] (5%%)  %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  10 && value >=  10)); then printf "%s[##..........................] (10%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  15 && value >=  15)); then printf "%s[###.........................] (15%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  20 && value >=  20)); then printf "%s[####........................] (20%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  25 && value >=  25)); then printf "%s[#####.......................] (25%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  30 && value >=  30)); then printf "%s[######......................] (30%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  35 && value >=  35)); then printf "%s[#######.....................] (35%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  40 && value >=  40)); then printf "%s[########....................] (40%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  45 && value >=  45)); then printf "%s[#########...................] (45%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  50 && value >=  50)); then printf "%s[##########..................] (50%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  55 && value >=  55)); then printf "%s[###########.................] (55%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  60 && value >=  60)); then printf "%s[############................] (60%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  65 && value >=  65)); then printf "%s[#############...............] (65%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  70 && value >=  70)); then printf "%s[##############..............] (70%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  75 && value >=  75)); then printf "%s[################............] (75%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  80 && value >=  80)); then printf "%s[##################..........] (80%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  85 && value >=  85)); then printf "%s[#####################.......] (85%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  90 && value >=  90)); then printf "%s[########################....] (90%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <=  95 && value >=  95)); then printf "%s[###########################.] (95%%) %s\r" "$clear_line" "$message"; delay; fi
  if ((_omb_plugin_progress_value <= 100 && value >= 100)); then
    # Display the finished progress bar, and then clear with a new line.
    printf "%s[############################] (100%%) %s\r" "$clear_line" "$message"
    delay
    printf 'Done!%s\n' "$clear_line"
    value=0
  fi

  _omb_plugin_progress_value=$value
}
