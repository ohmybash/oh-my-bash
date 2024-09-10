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

function return_delimited {
  # 1 = flag 2 = tag 3 = value
  if [[ $1 = "true" ]]; then
    printf "$2 $3---"
  elif [[ $1 = "false" ]]; then
    printf "$2 $3"
  else
    printf "$1 $2"
  fi
}

function extract_key {
  value=$(echo "$1" | grep -oP "(?<=$2)[^---]+")
  printf "$value"
}

function __bobby_clock {
  printf "$(clock_prompt) "

  if [ "${THEME_SHOW_CLOCK_CHAR}" == "true" ]; then
    printf "$(clock_char) "
  fi
}

function node_version {
  val_node=$(node --version)
  if command -v nvm &>/dev/null; then
    return_delimited $1 "node" "nvm ${val_node}"
  else
    # Si nvm no está instalado, utilizar "njs"
    return_delimited $1 "node" "njs ${val_node}"
  fi
}

function go_version {
  local val_go=$(go version | cut -d ' ' -f 3 | cut -d 'o' -f 2)
  return_delimited $1 "go" "go ${val_go}"
}

function ruby_version {
  local val_rb=$(ruby --version | cut -d ' ' -f 2)
  if command -v rvm &>/dev/null; then
    return_delimited $1 "ruby" "rvm ${val_rb}"
  else
    # Si nvm no está instalado, utilizar "njs"
    return_delimited $1 "ruby" "rb ${val_rb}"
  fi
}

function py_version {
  local val_py=$(python --version | cut -d ' ' -f 2)
  if command -v conda &>/dev/null; then
    local condav=$(conda env list | grep '*' | awk '{print $1}')
    return_delimited $1 "python" "conda<${condav}> ${val_py}"
  else
    # Si nvm no está instalado, utilizar "njs"
    return_delimited $1 "python" "py ${val_py}"
  fi
}

function OPi5p_Temp {
  local temp_opi5p=$(cat /sys/class/thermal/thermal_zone4/temp &)
  local temp_in_c=$((temp_opi5p / 1000))
  printf "${temp_in_c}"
}

function genericLinuxTemp {
  local temp_lnx=$(cat /sys/class/thermal/thermal_zone0/temp &)
  local temp_in_c=$((temp_lnx / 1000))
  printf "${temp_in_c}"
}

# if is a specific platfor use spacific configuration otherwise use default linux configuration.
function currentPlatform {
  # 2 ways to detect the platform 1) use a env var 2) some scrapping from the current system info (this is bash so just linux is considered)
  # env var is $PROMPT_THEME_PLATFORM
  #TODO: this is a first basic implementation this could be better but for now is ok
  local platform_according_env=$(echo $PROMPT_THEME_PLATFORM &)
  #echo $platform_according_env

  # if opi5 -> search for rk3588 tag in kernel and ...
  local opi5p_kernel_tag=$(uname --kernel-release | cut -d '-' -f 3 &)
  #echo $opi5p_kernel_tag

  if [[ $platform_according_env == "OPI5P" || $opi5p_kernel_tag == "rk3588" ]]; then
    printf "OPI5P"
  else
    printf "linux"
  fi
}

function cpu_load {
  # Ejecutar el comando top en modo batch, filtrar por el nombre de usuario actual y almacenar la salida en la variable 'output'
  local output=$(top -b -n 1 -u $USER | grep "Cpu(s)" &)

  # Extraer el porcentaje de carga de la CPU excluyendo el estado "idle" usando awk
  local cpu_load=$(echo "$output" | awk '{print 100.0-$8}' | cut -d '.' -f 1 &)

  # Imprimir la carga de la CPU
  printf "${cpu_load}"
}

function getCpuLoad {
  local current_cpu_load=$(cpu_load &)

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
  return_delimited $1 "cpuload" "${color}${current_cpu_load}"
}

function getCpuTemp {
  local temp_in_c
  local currentPlatform=$(currentPlatform)

  if ((currentPlatform == "linux")); then
    temp_in_c=$(genericLinuxTemp)
  elif ((currentPlatform == "OPI5P")); then
    temp_in_c=$(OPi5p_Temp)
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
  return_delimited $1 "cputemp" "${color}${temp_in_c}°"
}

# this should work on every "new" linux distro
function getDefaultIp {
  # Obtiene el nombre de la interfaz de red activa
  local interface=$(ip -o -4 route show to default | awk '{print $5}')

  # Obtiene la dirección IP de la interfaz de red activa
  local ip_address=$(ip -o -4 address show dev "$interface" | awk '{split($4, a, "/"); print a[1]}')

  return_delimited $1 "ip" "${ip_address}"
}

# prompt constructor
function _omb_theme_PROMPT_COMMAND() {
  # start_time=$(($(date +%s%N) / 1000000))

  #cputemp=$(getCpuTemp &)

  #cpuload=$(getCpuLoad &)

  #pyversion=$(py_version &)
  #nodeversion=$(node_version &)
  #goversion=$(go_version &)

  #defaultip=$(getDefaultIp &)

  #wait
  # NEW way using paralellism
  # this throws all inside the $() as a new thread but awaits the execution end_time
  # so this takes the same time as the slower function
  values=$(
    getCpuLoad true & # this is very slow
    getCpuTemp true &
    py_version true &
    node_version true &
    go_version true &
    getDefaultIp true &
  )

  cputemp=$(extract_key "$values" "cputemp")
  cpuload=$(extract_key "$values" "cpuload")
  nodeversion=$(extract_key "$values" "node")
  pyversion=$(extract_key "$values" "python")
  goversion=$(extract_key "$values" "go")

  defaultip=$(extract_key "$values" "ip")

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
