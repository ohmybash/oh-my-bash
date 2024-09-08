#! bash oh-my-bash.module

function _omb_plugin_battery__upower_print_info {
  upower -i "$(upower -e | sed -n '/BAT/{p;q;}')"
}

## @fn ac_adapter_connected
##   @exit 0 if the adapter is disconnected, or non-zero exit status
##     otherwise.
function ac_adapter_connected {
  if _omb_util_command_exists upower; then
    _omb_plugin_battery__upower_print_info | grep -qE 'state[:[:blank:]]*(charging|fully-charged)'
  elif _omb_util_command_exists acpi; then
    acpi -a | grep -q "on-line"
  elif _omb_util_command_exists pmset; then
    pmset -g batt | grep -q 'AC Power'
  elif _omb_util_command_exists ioreg; then
    ioreg -n AppleSmartBattery -r | grep -q '"ExternalConnected" = Yes'
  elif _omb_util_command_exists WMIC; then
    WMIC Path Win32_Battery Get BatteryStatus /Format:List | grep -q 'BatteryStatus=2'
  elif [[ -r /sys/class/power_supply/ADP0/online ]]; then
    [[ $(< /sys/class/power_supply/ADP0/online) == 1 ]]
  fi
}

## @fn ac_adapter_disconnected
##   @exit 0 if the adapter is disconnected, or non-zero exit status
##     otherwise.
function ac_adapter_disconnected {
  if _omb_util_command_exists upower; then
    _omb_plugin_battery__upower_print_info | grep -qE 'state[:[:blank:]]*discharging'
  elif _omb_util_command_exists acpi; then
    acpi -a | grep -q "off-line"
  elif _omb_util_command_exists pmset; then
    pmset -g batt | grep -q 'Battery Power'
  elif _omb_util_command_exists ioreg; then
    ioreg -n AppleSmartBattery -r | grep -q '"ExternalConnected" = No'
  elif _omb_util_command_exists WMIC; then
    WMIC Path Win32_Battery Get BatteryStatus /Format:List | grep -q 'BatteryStatus=1'
  elif [[ -r /sys/class/power_supply/ADP0/online ]]; then
    [[ $(< /sys/class/power_supply/ADP0/online) == 0 ]]
  fi
}

## @fn battery_percentage
##   @about 'displays battery charge as a percentage of full (100%)'
##   @group 'battery'
function battery_percentage {
  if _omb_util_command_exists upower; then
    local UPOWER_OUTPUT=$(_omb_plugin_battery__upower_print_info | sed -n 's/.*percentage[:[:blank:]]*\([0-9%]\{1,\}\)$/\1/p')
    [[ $UPOWER_OUTPUT ]] &&
      _omb_util_print "${UPOWER_OUTPUT::-1}"
  elif _omb_util_command_exists acpi; then
    local ACPI_OUTPUT=$(acpi -b)
    case $ACPI_OUTPUT in
      *" Unknown"*)
        local PERC_OUTPUT=$(head -c 22 <<< "$ACPI_OUTPUT" | tail -c 2)
        case $PERC_OUTPUT in
          *%)
            head -c 2 <<< "0${PERC_OUTPUT}"
          ;;
          *)
            _omb_util_print ${PERC_OUTPUT}
          ;;
        esac
      ;;

      *" Charging"* | *" Discharging"*)
        local PERC_OUTPUT=$(awk -F, '/,/{gsub(/ /, "", $0); gsub(/%/,"", $0); print $2}' <<< "$ACPI_OUTPUT")
        _omb_util_print ${PERC_OUTPUT}
      ;;
      *" Full"*)
        _omb_util_print '100'
      ;;
      *)
        _omb_util_print '-1'
      ;;
    esac
  elif _omb_util_command_exists pmset; then
    local PMSET_OUTPUT=$(pmset -g ps | sed -n 's/.*[[:blank:]]+*\(.*%\).*/\1/p')
    case $PMSET_OUTPUT in
      100*)
        _omb_util_print '100'
      ;;
      *)
        head -c 2 <<< "$PMSET_OUTPUT"
      ;;
    esac
  elif _omb_util_command_exists ioreg; then
    local IOREG_OUTPUT=$(ioreg -n AppleSmartBattery -r | awk '$1~/Capacity/{c[$1]=$3} END{OFMT="%05.2f%%"; max=c["\"MaxCapacity\""]; print (max>0? 100*c["\"CurrentCapacity\""]/max: "?")}')
    case $IOREG_OUTPUT in
      100*)
        _omb_util_print '100'
      ;;
      *)
        head -c 2 <<< "$IOREG_OUTPUT"
      ;;
    esac
  elif _omb_util_command_exists WMIC; then
    local WINPC=$(grep -o '[0-9]*' <<< "porcent=$(WMIC PATH Win32_Battery Get EstimatedChargeRemaining /Format:List)")
    case $WINPC in
      100*)
        _omb_util_print '100'
      ;;
      *)
        _omb_util_print $WINPC
      ;;
    esac
  elif [[ -r /sys/class/power_supply/BAT0/capacity ]]; then
    _omb_util_print "$(< /sys/class/power_supply/BAT0/capacity)"
  fi
}

## @fn battery_charge
##   @about 'graphical display of your battery charge'
##   @group 'battery'
function battery_charge {
  # Full char
  local F_C='▸'
  # Depleted char
  local D_C='▹'
  local DEPLETED_COLOR="${_omb_prompt_normal}"
  local FULL_COLOR="${_omb_prompt_green}"
  local HALF_COLOR="${_omb_prompt_olive}"
  local DANGER_COLOR="${_omb_prompt_brown}"
  local BATTERY_OUTPUT="${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${D_C}"
  local BATTERY_PERC=$(battery_percentage)

  case $BATTERY_PERC in
    no)
      _omb_util_print ""
    ;;
    9*)
      _omb_util_print "${FULL_COLOR}${F_C}${F_C}${F_C}${F_C}${F_C}${_omb_prompt_normal}"
    ;;
    8*)
      _omb_util_print "${FULL_COLOR}${F_C}${F_C}${F_C}${F_C}${HALF_COLOR}${F_C}${_omb_prompt_normal}"
    ;;
    7*)
      _omb_util_print "${FULL_COLOR}${F_C}${F_C}${F_C}${F_C}${DEPLETED_COLOR}${D_C}${_omb_prompt_normal}"
    ;;
    6*)
      _omb_util_print "${FULL_COLOR}${F_C}${F_C}${F_C}${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${_omb_prompt_normal}"
    ;;
    5*)
      _omb_util_print "${FULL_COLOR}${F_C}${F_C}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${_omb_prompt_normal}"
    ;;
    4*)
      _omb_util_print "${FULL_COLOR}${F_C}${F_C}${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${_omb_prompt_normal}"
    ;;
    3*)
      _omb_util_print "${FULL_COLOR}${F_C}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${_omb_prompt_normal}"
    ;;
    2*)
      _omb_util_print "${FULL_COLOR}${F_C}${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${_omb_prompt_normal}"
    ;;
    1*)
      _omb_util_print "${FULL_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${_omb_prompt_normal}"
    ;;
    05)
      _omb_util_print "${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${_omb_prompt_normal}"
    ;;
    04)
      _omb_util_print "${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${_omb_prompt_normal}"
    ;;
    03)
      _omb_util_print "${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${_omb_prompt_normal}"
    ;;
    02)
      _omb_util_print "${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${_omb_prompt_normal}"
    ;;
    0*)
      _omb_util_print "${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${_omb_prompt_normal}"
    ;;
    *)
      _omb_util_print "${DANGER_COLOR}UNPLG${_omb_prompt_normal}"
    ;;
  esac
}
