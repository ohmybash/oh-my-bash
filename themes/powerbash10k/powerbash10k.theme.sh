#! bash oh-my-bash.module

# powerbash10k theme for oh-my-bash, inspired by powerlevel10k zsh theme
# made by awerebea, based on brainy theme by MunifTanjim

# Helpers
function __pb10k_remove_empty_elements {
    local origin_array new_array element trimmed
    IFS="|" read -ra origin_array <<< "$1"
    new_array=()
    for element in "${origin_array[@]}"; do
        trimmed="${element#"${element%%[![:space:]]*}"}"
        trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
        if [ "$trimmed" != "" ]; then
            new_array+=("$element")
        fi
    done
    echo "${new_array[@]}"
}

function __pb10k_format_duration {
    local duration seconds minutes hours
    duration=$1
    seconds=$((duration % 60))
    minutes=$((duration / 60 % 60))
    hours=$((duration / 3600))

    if ((hours > 0)); then
        echo "${hours}h ${minutes}m ${seconds}s"
    elif ((minutes > 0)); then
        echo "${minutes}m ${seconds}s"
    else
        echo "${seconds}s"
    fi
}

# Last command duration
function __pb10k_timer_start {
    __pb10k_timer=${__pb10k_timer:-$SECONDS}
}

function __pb10k_timer_stop {
    __pb10k_timer_show=$((SECONDS - __pb10k_timer))
    unset __pb10k_timer
}

trap '__pb10k_timer_start' DEBUG

# Parsers
function __pb10k_top_left_parse {
    local args
    IFS="|" read -ra args <<< "$1"
    if [ "${args[3]}" != "" ]; then
        __TOP_LEFT+="${args[2]}${args[3]}"
    fi
    __TOP_LEFT+="${args[0]}${args[1]}"
    if [ "${args[4]}" != "" ]; then
        __TOP_LEFT+="${args[2]}${args[4]}"
    fi
    __TOP_LEFT+=" "
}

function __pb10k_top_right_parse {
    local args
    IFS="|" read -ra args <<< "$1"
    __TOP_RIGHT+=" "
    if [ "${args[3]}" != "" ]; then
        __TOP_RIGHT+="${args[2]}${args[3]}"
    fi
    __TOP_RIGHT+="${args[0]}${args[1]}"
    if [ "${args[4]}" != "" ]; then
        __TOP_RIGHT+="${args[2]}${args[4]}"
    fi
    __TOP_RIGHT_LEN=$(( __TOP_RIGHT_LEN + ${#args[1]} + ${#args[3]} + ${#args[4]} + 1 ))
    (( __SEG_AT_RIGHT += 1 ))
}

function __pb10k_bottom_parse {
    local args
    IFS="|" read -ra args <<< "$1"
    __BOTTOM+="${args[0]}${args[1]}"
    [ ${#args[1]} -gt 0 ] && __BOTTOM+=" "
}

function __pb10k_top {
    local seg segments info terminal_width filler_character cursor_adjust
    local __TOP_LEFT=""
    local __TOP_RIGHT=""
    local __TOP_RIGHT_LEN=0
    local __SEG_AT_RIGHT=0

    IFS=" " read -ra segments <<< "$__PB10K_TOP_LEFT"
    for seg in "${segments[@]}"; do
        info="$(__pb10k_prompt_"$seg")"
        [ "$info" != "" ] && __pb10k_top_left_parse "$info"
    done

    terminal_width=$(tput cols)
    filler_character="·"
    __TOP_LEFT+="$_omb_prompt_black"
    __TOP_LEFT+="$(for ((i=0; i<"$terminal_width"; i++)); do printf "%s" "$filler_character"; done)"
    __TOP_LEFT+="\033[${terminal_width}G\033[1K\033[1A"

    IFS=" " read -ra segments <<< "$__PB10K_TOP_RIGHT"
    for seg in "${segments[@]}"; do
        info="$(__pb10k_prompt_"$seg")"
        [ "$info" != "" ] && __pb10k_top_right_parse "$info"
    done

    [ "$__TOP_RIGHT_LEN" -gt 0 ] && __TOP_RIGHT_LEN=$(( __TOP_RIGHT_LEN - 1 ))
    cursor_adjust="\033[${__TOP_RIGHT_LEN}D"
    __TOP_LEFT+="$cursor_adjust"

    printf "%s%s" "$__TOP_LEFT" "$__TOP_RIGHT"
}

function __pb10k_bottom {
    local seg segments info
    local __BOTTOM=""
    IFS=" " read -ra segments <<< "$__PB10K_BOTTOM"
    for seg in "${segments[@]}"; do
        info="$(__pb10k_prompt_"$seg")"
        [ "$info" != "" ] && __pb10k_bottom_parse "$info"
    done
    printf "\n%s" "$__BOTTOM"
}

# Segments
function __pb10k_prompt_user_info {
    local color box info
    color=$_omb_prompt_bold_olive
    if [ "$THEME_SHOW_SUDO" == "true" ]; then
        if sudo -n id -u 2>&1 | grep -q 0; then
            color=$_omb_prompt_bold_brown
        fi
    fi
    box=""
    info="$USER@$(hostname | cut -d'.' -f1)"
    if [ "$SSH_CLIENT" != "" ]; then
        printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_white" "$box"
    elif [ "$__PB10K_PROMPT_LOCAL_USER_INFO" == "true" ]; then
        printf "%s|%s" "$color" "$info"
    fi
}

function __pb10k_prompt_dir {
    local color box info
    color=$_omb_prompt_bold_navy
    box=""
    info="  \w"
    printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_white" "$box"
}

function __pb10k_prompt_scm {
    local color box info
    [ "$THEME_SHOW_SCM" != "true" ] && return
    color=$_omb_prompt_bold_green
    scm
    box=""
    info="$(if [ "$SCM" == "git" ]; then echo "  "; fi)"
    info+="$(if [ "$SCM" != "NONE" ]; then echo " $(scm_prompt_info)"; fi)"
    [ "$info" == "" ] && return
    printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_green" "$box"
}

function __pb10k_prompt_python {
    local color box info response_array venvs
    [ "$THEME_SHOW_PYTHON" != "true" ] && return
    color=$_omb_prompt_bold_olive
    box=""
    read -ra response_array <<< "$(__pb10k_remove_empty_elements "$(python_version_prompt)")"
    info="${response_array[-1]}"
    if [ ${#response_array[@]} -gt 1 ]; then
        # Print all elements except the last one, separated by commas
        venvs=$(printf "%s," "${response_array[@]:0:${#response_array[@]}-1}")
        # Remove the trailing comma
        venvs="${venvs%,}"
        info="${info} (${venvs})"
    fi
    info="${info/#py-/ }"
    [ ${#response_array[@]} -lt 2 ] && return
    printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_navy" "$box"
}

function __pb10k_prompt_ruby {
    local color box info
    [ "$THEME_SHOW_RUBY" != "true" ] && return
    color=$_omb_prompt_bold_white
    box="[|]"
    info="rb-$(_omb_prompt_print_ruby_env)"
    printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_brown" "$box"
}

function __pb10k_prompt_todo {
    local color box info
    [ "$THEME_SHOW_TODO" != "true" ] && return
    _omb_util_binary_exists todo.sh || return
    color=$_omb_prompt_bold_white
    box="[|]"
    info="t:$(todo.sh ls | command grep -E "TODO: [0-9]+ of ([0-9]+)" | awk '{ print $4 }' )"
    printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_green" "$box"
}

function __pb10k_prompt_clock {
    local color box info
    [ "$THEME_SHOW_CLOCK" != "true" ] && return
    color=$THEME_CLOCK_COLOR
    box=""
    info=" $(date +"$THEME_CLOCK_FORMAT")"
    printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_purple" "$box"
}

function __pb10k_prompt_battery {
    local color box info
    [ ! -e "$OSH/plugins/battery/battery.plugin.sh" ] ||
    [ "$THEME_SHOW_BATTERY" != "true" ] && return
    info=$(battery_percentage)
    color=$_omb_prompt_bold_green
    if [ "$info" -lt 50 ]; then
        color=$_omb_prompt_bold_olive
    elif [ "$info" -lt 25 ]; then
        color=$_omb_prompt_bold_brown
    fi
    box="[|]"
    ac_adapter_connected && info+="+"
    [ "$info" == "100+" ] && info="AC"
    printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_white" "$box"
}

function __pb10k_prompt_exitcode {
    local color
    [ "$THEME_SHOW_EXITCODE" != "true" ] && return
    color=$_omb_prompt_bold_red
    [ "$exitcode" -ne 0 ] && printf "%s|%s" "$color" "✘ ${exitcode}"
}

function __pb10k_prompt_char {
    local color
    color=$(if [ "$exitcode" -ne 0 ]; then
            echo "$_omb_prompt_bold_red"
        else
            echo "$_omb_prompt_bold_green"
    fi)
    printf "%s|%s" "$color" "$__PB10K_PROMPT_CHAR_PS1"
}

function __pb10k_prompt_cmd_duration {
    local color box info
    color=$_omb_prompt_bold_navy
    box=""
    info="$(if [ "$__pb10k_timer_show" -gt 0 ]; then
        printf " %s" "$(__pb10k_format_duration "$__pb10k_timer_show")"
    fi)"
    [ "$info" == "" ] && return
    printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_white" "$box"
}

# cli
function __pb10k_show {
    local seg
    seg="${1:-}"
    shift
    export THEME_SHOW_"$seg"=true
}

function __pb10k_hide {
    local seg
    seg="${1:-}"
    shift
    export THEME_SHOW_"$seg"=false
}

function __pb10k_completion {
    local cur action actions segments
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    action="${COMP_WORDS[1]}"
    actions="show hide"
    segments="battery clock exitcode python ruby scm sudo todo"
    case "$action" in
        show)
        COMPREPLY=( "$(compgen -W "$segments" -- "$cur")" )
        return 0
        ;;
        hide)
        COMPREPLY=( "$(compgen -W "$segments" -- "$cur")" )
        return 0
        ;;
    esac

    COMPREPLY=( "$(compgen -W "$actions" -- "$cur")" )
    return 0
}

function pb10k {
    local action segments seg
    action="${1:-}"
    shift
    segments="${*:-}"
    typeset func
    case "$action" in
        show)
        func=__pb10k_show;;
        hide)
        func=__pb10k_hide;;
    esac
    IFS=" " read -ra segments <<< "$segments"
    for seg in "${segments[@]}"; do
        seg=$(printf "%s" "$seg" | tr '[:lower:]' '[:upper:]')
        "$func" "$seg"
    done
}

complete -F __pb10k_completion pb10k

# Variables
export SCM_THEME_PROMPT_PREFIX=""
export SCM_THEME_PROMPT_SUFFIX=""

export RBENV_THEME_PROMPT_PREFIX=""
export RBENV_THEME_PROMPT_SUFFIX=""
export RBFU_THEME_PROMPT_PREFIX=""
export RBFU_THEME_PROMPT_SUFFIX=""
export RVM_THEME_PROMPT_PREFIX=""
export RVM_THEME_PROMPT_SUFFIX=""

export SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}✗${_omb_prompt_normal}"
export SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"

THEME_SHOW_SUDO=${THEME_SHOW_SUDO:-"true"}
THEME_SHOW_SCM=${THEME_SHOW_SCM:-"true"}
THEME_SHOW_RUBY=${THEME_SHOW_RUBY:-"false"}
THEME_SHOW_PYTHON=${THEME_SHOW_PYTHON:-"false"}
THEME_SHOW_CLOCK=${THEME_SHOW_CLOCK:-"true"}
THEME_SHOW_TODO=${THEME_SHOW_TODO:-"false"}
THEME_SHOW_BATTERY=${THEME_SHOW_BATTERY:-"false"}
THEME_SHOW_EXITCODE=${THEME_SHOW_EXITCODE:-"true"}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$_omb_prompt_bold_white"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%H:%M:%S"}

__PB10K_PROMPT_CHAR_PS1=${THEME_PROMPT_CHAR_PS1:-"❯"}
__PB10K_PROMPT_CHAR_PS2=${THEME_PROMPT_CHAR_PS2:-"\\"}

__PB10K_TOP_LEFT=${__PB10K_TOP_LEFT:-"dir scm"}
__PB10K_TOP_RIGHT=${__PB10K_TOP_RIGHT:-"exitcode cmd_duration user_info python ruby todo clock battery"}
__PB10K_BOTTOM=${__PB10K_BOTTOM:-"char"}
__PB10K_PROMPT_LOCAL_USER_INFO=${__PB10K_PROMPT_LOCAL_USER_INFO:-"true"}

# Prompt
function __pb10k_ps1 {
    printf "%s%s%s" "$(__pb10k_top)" "$(__pb10k_bottom)" "$_omb_prompt_normal"
}

function __pb10k_ps2 {
    local color
    color=$_omb_prompt_bold_white
    printf "%s%s%s" "$color" "${__PB10K_PROMPT_CHAR_PS2}  " "$_omb_prompt_normal"
}

function _omb_theme_PROMPT_COMMAND {
    local exitcode="$?"
    PS1="$(__pb10k_ps1)"
    PS2="$(__pb10k_ps2)"
}

_omb_util_add_prompt_command __pb10k_timer_stop
_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
