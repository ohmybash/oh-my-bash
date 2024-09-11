#! bash oh-my-bash.module

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" $_omb_prompt_green|"
SCM_THEME_PROMPT_SUFFIX="$_omb_prompt_green|"

GIT_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" $_omb_prompt_green|"
GIT_THEME_PROMPT_SUFFIX="$_omb_prompt_green|"

RVM_THEME_PROMPT_PREFIX='|'
RVM_THEME_PROMPT_SUFFIX='|'

function __bobby_clock {
  _omb_util_put "$(clock_prompt) "

  if [[ $THEME_SHOW_CLOCK_CHAR == true ]]; then
    _omb_util_put "$(clock_char) "
  fi
}

## @var[out] REPLY
function _omb_theme_developer__readNodeVersion {
  local val_node=$(node --version 2>/dev/null)
  if _omb_util_command_exists nvm; then
    val_node="nvm $val_node"
  else
    # Si nvm no está instalado, utilizar "njs"
    val_node="njs $val_node"
  fi
  REPLY=$val_node
}

## @var[out] REPLY
function _omb_theme_developer__readGoVersion {
  local val_go=$(go version 2>/dev/null | cut -d ' ' -f 3 | cut -d 'o' -f 2)
  REPLY="go $val_go"
}

## @var[out] REPLY
function _omb_theme_developer__read_ruby_version {
  local val_rb=$(ruby --version 2>/dev/null | cut -d ' ' -f 2)
  if _omb_util_command_exists rvm; then
    val_rb="rvm $val_rb"
  else
    # Si nvm no está instalado, utilizar "njs"
    val_rb="rb $val_rb"
  fi
  REPLY=$val_rb
}

## @var[out] REPLY
function _omb_theme_developer__readPyVersion {
  local val_py=$(python --version 2>/dev/null | cut -d ' ' -f 2)
  if _omb_util_command_exists conda; then
    local condav=$(conda env list | awk '$2 == "*" {print $1}')
    val_py="conda<$condav> $val_py"
  else
    # Si nvm no está instalado, utilizar "njs"
    val_py="py $val_py"
  fi
  REPLY=$val_py
}

## @var[out] REPLY
function _omb_theme_developer__readCpuLoad__cpuLoad {
  # Ejecutar el comando top en modo batch, filtrar por el nombre de usuario
  # actual.  Extraer el porcentaje de carga de la CPU excluyendo el estado
  # "idle" usando awk
  local cpu_load=$(top -b -n 1 -u "$USER" | awk -F ',' '/Cpu\(s\)/ {gsub(/[^.0-9]/,"",$4);printf("%d", 100.0 - $4)}')

  # Almacenar la carga de la CPU en la variable 'REPLY'
  REPLY=$cpu_load
}

## @var[out] REPLY
function _omb_theme_developer__readCpuLoad {
  _omb_theme_developer__readCpuLoad__cpuLoad
  local current_cpu_load=$REPLY

  local color=$_omb_prompt_reset_color
  # Condicional para verificar los rangos
  if ((current_cpu_load <= 40)); then
    color=$_omb_prompt_teal
  elif ((current_cpu_load >= 41 && current_cpu_load <= 50)); then
    color=$_omb_prompt_reset_color
  elif ((current_cpu_load >= 51 && current_cpu_load <= 60)); then
    color=$_omb_prompt_olive
  elif ((current_cpu_load >= 61 && current_cpu_load <= 75)); then
    color=$_omb_prompt_red
  elif ((current_cpu_load >= 76)); then
    color=$_omb_prompt_red'!'
  fi
  REPLY=$color$current_cpu_load
}

## @var[out] REPLY
function _omb_theme_developer__readCpuTemp_genericLinuxTemp {
  local file=${1:-/sys/class/thermal/thermal_zone0/temp}
  if [[ ! -e $file ]]; then
    REPLY=
    return 1
  fi

  local temp_linux=$(< "$file")
  local temp_in_c=$((temp_linux / 1000))
  REPLY=$temp_in_c
}

## @var[out] REPLY
function _omb_theme_developer__readCpuTemp_OPi5pTemp {
  _omb_theme_developer__readCpuTemp_genericLinuxTemp /sys/class/thermal/thermal_zone4/temp
}

# if is a specific platfor use spacific configuration otherwise use default
# linux configuration.
## @var[out] REPLY
function _omb_theme_developer__readCpuTemp_currentPlatform {
  # 2 ways to detect the platform 1) use a env var 2) some scrapping from the
  # current system info (this is bash so just linux is considered) env var is
  # $PROMPT_THEME_PLATFORM
  # TODO: this is a first basic implementation this could be better but for now
  # is ok
  local platform_according_env=$PROMPT_THEME_PLATFORM

  # if opi5 -> search for rk3588 tag in kernel and ...
  local opi5p_kernel_tag=$(uname --kernel-release 2>/dev/null | cut -d '-' -f 3)

  if [[ $platform_according_env == OPI5P || $opi5p_kernel_tag == rk3588 ]]; then
    REPLY=OPI5P
  else
    REPLY=linux
  fi
}

## @var[out] REPLY
function _omb_theme_developer__readCpuTemp {
  _omb_theme_developer__readCpuTemp_currentPlatform
  local currentPlatform=$REPLY

  if [[ $currentPlatform == linux ]]; then
    _omb_theme_developer__readCpuTemp_genericLinuxTemp
  elif [[ $currentPlatform == OPI5P ]]; then
    _omb_theme_developer__readCpuTemp_OPi5pTemp
  fi
  local temp_in_c=$REPLY
  [[ $REPLY ]] || return 0

  local color
  # Condicional para verificar los rangos
  if ((temp_in_c >= 1 && temp_in_c <= 40)); then
    color=$_omb_prompt_teal
  elif ((temp_in_c >= 41 && temp_in_c <= 50)); then
    color=$_omb_prompt_reset_color
  elif ((temp_in_c >= 51 && temp_in_c <= 60)); then
    color=$_omb_prompt_olive
  elif ((temp_in_c >= 61 && temp_in_c <= 75)); then
    color=$_omb_prompt_red
  elif ((temp_in_c >= 76 && temp_in_c)); then
    color=$_omb_prompt_red!
  fi
  REPLY="$color${temp_in_c}°"
}

## @var[out] REPLY
function _omb_theme_developer__readDefaultIp {
  # this should work on every "new" linux distro

  # Obtiene el nombre de la interfaz de red activa
  local interface=$(ip -o -4 route show to default 2>/dev/null | awk '{print $5}')

  # Obtiene la dirección IP de la interfaz de red activa
  local ip_address=$(ip -o -4 address show dev "$interface" 2>/dev/null | awk '{split($4, a, "/"); print a[1]}')

  REPLY=$ip_address
}

# prompt constructor
function _omb_theme_PROMPT_COMMAND {
  local REPLY
  _omb_theme_developer__readCpuTemp
  local cputemp=$REPLY
  _omb_theme_developer__readCpuLoad # this is very slow
  local cpuload=$REPLY
  _omb_theme_developer__readPyVersion
  local pyversion=$REPLY
  _omb_theme_developer__readNodeVersion
  local nodeversion=$REPLY
  _omb_theme_developer__readGoVersion
  local goversion=$REPLY
  _omb_theme_developer__readDefaultIp
  local defaultip=$REPLY

  local tech_versions=$nodeversion
  [[ $pyversion ]] && tech_versions+=${tech_versions:+$RVM_THEME_PROMPT_PREFIX}$pyversion
  [[ $goversion ]] && tech_versions+=${tech_versions:+$RVM_THEME_PROMPT_PREFIX}$goversion
  [[ $tech_versions ]] && tech_versions=$_omb_prompt_reset_color$tech_versions

  local top_bar="\n$(battery_char)$(__bobby_clock)$tech_versions${cputemp:+ $cputemp}${cpuload:+ $cpuload%} $_omb_prompt_purple\h${defaultip:+ ($defaultip)} ${_omb_prompt_reset_color}in $_omb_prompt_green\w\n"

  local prompt_line="$_omb_prompt_bold_teal$(scm_prompt_char_info) $_omb_prompt_green→$_omb_prompt_reset_color "

  # defining the final prompt
  PS1="$top_bar$prompt_line"
}

THEME_SHOW_CLOCK_CHAR=${THEME_SHOW_CLOCK_CHAR:-"true"}
THEME_CLOCK_CHAR_COLOR=${THEME_CLOCK_CHAR_COLOR:-"$_omb_prompt_brown"}
THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$_omb_prompt_bold_teal"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%Y-%m-%d %H:%M"}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
