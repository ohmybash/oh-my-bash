#! bash oh-my-bash.module

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" ${_omb_prompt_green}|"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_green}|"

GIT_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${_omb_prompt_green}|"
GIT_THEME_PROMPT_SUFFIX="${_omb_prompt_green}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function _omb_theme_developer_return_delimited {
  # $1 = tag, $2 = value
  _omb_util_print "$1 $2"
}

function _omb_theme_developer_extract_key {
  value=$(sed -n "s/^$2 //p" <<< "$1")
  _omb_util_put "$value"
}

function __bobby_clock {
  _omb_util_put "$(clock_prompt) "

  if [ "${THEME_SHOW_CLOCK_CHAR}" == "true" ]; then
    _omb_util_put "$(clock_char) "
  fi
}

function _omb_theme_developer_get_node_version {
  val_node=$(node --version)
  if _omb_util_command_exists nvm; then
    _omb_theme_developer_return_delimited "node" "nvm ${val_node}"
  else
    # Si nvm no está instalado, utilizar "njs"
    _omb_theme_developer_return_delimited "node" "njs ${val_node}"
  fi
}

function _omb_theme_developer_get_go_version {
  local val_go=$(go version | cut -d ' ' -f 3 | cut -d 'o' -f 2)
  _omb_theme_developer_return_delimited "go" "go ${val_go}"
}

function _omb_theme_developer_get_ruby_version {
  local val_rb=$(ruby --version | cut -d ' ' -f 2)
  if _omb_util_command_exists rvm; then
    _omb_theme_developer_return_delimited "ruby" "rvm ${val_rb}"
  else
    # Si nvm no está instalado, utilizar "njs"
    _omb_theme_developer_return_delimited "ruby" "rb ${val_rb}"
  fi
}

function _omb_theme_developer_get_py_version {
  local val_py=$(python --version | cut -d ' ' -f 2)
  if _omb_util_command_exists conda; then
    local condav=$(conda env list | awk '$2 == "*" {print $1}')
    _omb_theme_developer_return_delimited "python" "conda<${condav}> ${val_py}"
  else
    # Si nvm no está instalado, utilizar "njs"
    _omb_theme_developer_return_delimited "python" "py ${val_py}"
  fi
}

function _omb_theme_developer_OPi5p_Temp {
  local temp_opi5p=$(< /sys/class/thermal/thermal_zone4/temp)
  local temp_in_c=$((temp_opi5p / 1000))
  _omb_util_put "${temp_in_c}"
}

function _omb_theme_developer_genericLinuxTemp {
  local temp_lnx=$(< /sys/class/thermal/thermal_zone0/temp)
  local temp_in_c=$((temp_lnx / 1000))
  _omb_util_put "${temp_in_c}"
}

# if is a specific platfor use spacific configuration otherwise use default linux configuration.
function _omb_theme_developer_currentPlatform {
  # 2 ways to detect the platform 1) use a env var 2) some scrapping from the current system info (this is bash so just linux is considered)
  # env var is $PROMPT_THEME_PLATFORM
  #TODO: this is a first basic implementation this could be better but for now is ok
  local platform_according_env=$PROMPT_THEME_PLATFORM
  #echo $platform_according_env

  # if opi5 -> search for rk3588 tag in kernel and ...
  local opi5p_kernel_tag=$(uname --kernel-release | cut -d '-' -f 3)
  #echo $opi5p_kernel_tag

  if [[ $platform_according_env == "OPI5P" || $opi5p_kernel_tag == "rk3588" ]]; then
    _omb_util_put "OPI5P"
  else
    _omb_util_put "linux"
  fi
}

function _omb_theme_developer_cpu_load {
  # Ejecutar el comando top en modo batch, filtrar por el nombre de usuario actual y almacenar la salida en la variable 'output'
  local output=$(top -b -n 1 -u $USER | grep "Cpu(s)")

  # Extraer el porcentaje de carga de la CPU excluyendo el estado "idle" usando awk
  local cpu_load=$(echo "$output" | awk '{print 100.0-$8}' | cut -d '.' -f 1)

  # Imprimir la carga de la CPU
  _omb_util_put "${cpu_load}"
}

function _omb_theme_developer_getCpuLoad {
  local current_cpu_load=$(_omb_theme_developer_cpu_load)

  local color="${_omb_prompt_reset_color}"
  # Condicional para verificar los rangos
  if ((current_cpu_load <= 40)); then
    color="${_omb_prompt_teal}"
  elif ((current_cpu_load >= 41 && current_cpu_load <= 50)); then
    color="${_omb_prompt_reset_color}"
  elif ((current_cpu_load >= 51 && current_cpu_load <= 60)); then
    color="${_omb_prompt_olive}"
  elif ((current_cpu_load >= 61 && current_cpu_load <= 75)); then
    color="${_omb_prompt_red}"
  elif ((current_cpu_load >= 76)); then
    color="${_omb_prompt_red}!"
  fi
  _omb_theme_developer_return_delimited "cpuload" "${color}${current_cpu_load}"
}

function _omb_theme_developer_getCpuTemp {
  local temp_in_c
  local currentPlatform=$(_omb_theme_developer_currentPlatform)

  if ((currentPlatform == "linux")); then
    temp_in_c=$(_omb_theme_developer_genericLinuxTemp)
  elif ((currentPlatform == "OPI5P")); then
    temp_in_c=$(_omb_theme_developer_OPi5p_Temp)
  fi

  local color
  # Condicional para verificar los rangos
  if ((temp_in_c >= 1 && temp_in_c <= 40)); then
    color="${_omb_prompt_teal}"
  elif ((temp_in_c >= 41 && temp_in_c <= 50)); then
    color="${_omb_prompt_reset_color}"
  elif ((temp_in_c >= 51 && temp_in_c <= 60)); then
    color="${_omb_prompt_olive}"
  elif ((temp_in_c >= 61 && temp_in_c <= 75)); then
    color="${_omb_prompt_red}"
  elif ((temp_in_c >= 76 && temp_in_c)); then
    color="${_omb_prompt_red}!"
  fi
  _omb_theme_developer_return_delimited "cputemp" "${color}${temp_in_c}°"
}

# this should work on every "new" linux distro
function _omb_theme_developer_getDefaultIp {
  # Obtiene el nombre de la interfaz de red activa
  local interface=$(ip -o -4 route show to default | awk '{print $5}')

  # Obtiene la dirección IP de la interfaz de red activa
  local ip_address=$(ip -o -4 address show dev "$interface" | awk '{split($4, a, "/"); print a[1]}')

  _omb_theme_developer_return_delimited "ip" "${ip_address}"
}

# prompt constructor
function _omb_theme_PROMPT_COMMAND {
  # start_time=$(($(date +%s%N) / 1000000))

  #cputemp=$(_omb_theme_developer_getCpuTemp)
  #cpuload=$(_omb_theme_developer_getCpuLoad)
  #pyversion=$(_omb_theme_developer_get_py_version)
  #nodeversion=$(_omb_theme_developer_get_node_version)
  #goversion=$(_omb_theme_developer_get_go_version)
  #defaultip=$(_omb_theme_developer_getDefaultIp)

  # NEW way using paralellism
  # this throws all inside the $() as a new thread but awaits the execution end_time
  # so this takes the same time as the slower function
  values=$(
    _omb_theme_developer_getCpuLoad & # this is very slow
    _omb_theme_developer_getCpuTemp &
    _omb_theme_developer_get_py_version &
    _omb_theme_developer_get_node_version &
    _omb_theme_developer_get_go_version &
    _omb_theme_developer_getDefaultIp &
  )

  cputemp=$(_omb_theme_developer_extract_key "$values" "cputemp")
  cpuload=$(_omb_theme_developer_extract_key "$values" "cpuload")
  nodeversion=$(_omb_theme_developer_extract_key "$values" "node")
  pyversion=$(_omb_theme_developer_extract_key "$values" "python")
  goversion=$(_omb_theme_developer_extract_key "$values" "go")

  defaultip=$(_omb_theme_developer_extract_key "$values" "ip")

  #
  # end_time=$(($(date +%s%N) / 1000000))
  # elapsed_time=$((end_time - start_time))
  # echo "Tiempo total de ejecución: ${elapsed_time} milisegundos"

  tech_versions="${_omb_prompt_reset_color}${nodeversion}${RVM_THEME_PROMPT_PREFIX}${pyversion}${RVM_THEME_PROMPT_PREFIX}${goversion}"

  top_bar="\n$(battery_char)$(__bobby_clock)${tech_versions} ${cputemp} ${cpuload}% ${_omb_prompt_purple}\h (${defaultip}) ${_omb_prompt_reset_color}in ${_omb_prompt_green}\w\n"

  prompt_line="${_omb_prompt_bold_teal}$(scm_prompt_char_info) ${_omb_prompt_green}→${_omb_prompt_reset_color} "

  # defining the final prompt
  PS1="${top_bar}${prompt_line}"
}

THEME_SHOW_CLOCK_CHAR=${THEME_SHOW_CLOCK_CHAR:-"true"}
THEME_CLOCK_CHAR_COLOR=${THEME_CLOCK_CHAR_COLOR:-"$_omb_prompt_brown"}
THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$_omb_prompt_bold_teal"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%Y-%m-%d %H:%M"}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
