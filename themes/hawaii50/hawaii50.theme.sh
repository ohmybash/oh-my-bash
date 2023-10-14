#! bash oh-my-bash.module
#
# This theme was obviously inspired a lot by
#
# - Demula theme
#
# which in itself was inspired by :
#
# - Ronacher's dotfiles (mitsuhikos) - http://github.com/mitsuhiko/dotfiles/tree/master/bash/
# - Glenbot - http://theglenbot.com/custom-bash-shell-for-development/
# - My extravagant zsh - http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
# - Monokai colors - http://monokai.nl/blog/2006/07/15/textmate-color-theme/
# - Bash_it modern theme
#
# Hawaii50 theme supports :
#
# - configurable directory length
# - hg, svn, git detection (I work in all of them)
# - virtualenv, rvm + gemsets
#
# Screenshot: http://i.imgur.com/4IAMJ.png
#
# by Ryan Kanno <ryankanno@localkinegrinds.com>
#
# And yes, we code out in Hawaii. :D
#
# Note: I also am really new to this bash scripting game, so if you see things
# that are flat out wrong, or if you think of something neat, just send a pull
# request.  This probably only works on a Mac - as some functions are OS
# specific like getting ip, etc.
#

# IMPORTANT THINGS TO CHANGE ==================================================

# Show IP in prompt
# One thing to be weary about if you have slow Internets
IP_ENABLED=1

# virtual prompts
VIRTUAL_PROMPT_ENABLED=1

# COLORS ======================================================================
ORANGE='\[\e[0;33m\]'

DEFAULT_COLOR="${_omb_prompt_white}"

USER_COLOR="${_omb_prompt_purple}"
SUPERUSER_COLOR="${_omb_prompt_brown}"
MACHINE_COLOR=$ORANGE
IP_COLOR=$ORANGE
DIRECTORY_COLOR="${_omb_prompt_green}"

VE_COLOR="${_omb_prompt_teal}"
RVM_COLOR="${_omb_prompt_teal}"

REF_COLOR="${_omb_prompt_purple}"

# SCM prompts
SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}✗${_omb_prompt_normal}"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
SCM_THEME_PROMPT_PREFIX=' on '
SCM_THEME_PROMPT_SUFFIX=''

# rvm prompts
RVM_THEME_PROMPT_PREFIX=''
RVM_THEME_PROMPT_SUFFIX=''

# virtualenv prompts
OMB_PROMPT_VIRTUALENV_FORMAT='%s'
OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:=true}

VIRTUAL_THEME_PROMPT_PREFIX=' using '
VIRTUAL_THEME_PROMPT_SUFFIX=''

# Max length of PWD to display
MAX_PWD_LENGTH=20

# Max length of Git Hex to display
MAX_GIT_HEX_LENGTH=5

# IP address
IP_SEPARATOR=', '

# FUNCS =======================================================================

function get_ip_info {
    local myip=$(curl -s checkip.dyndns.org | grep -Eo '[0-9\.]+')
    echo -e "$(ips | sed -e :a -e '$!N;s/\n/${IP_SEPARATOR}/;ta' | sed -e 's/127\.0\.0\.1\${IP_SEPARATOR}//g'), ${myip}"
}

# Displays ip prompt
function ip_prompt_info() {
    if [[ $IP_ENABLED == 1 ]]; then
        echo -e " ${DEFAULT_COLOR}(${IP_COLOR}$(get_ip_info)${DEFAULT_COLOR})"
    fi
}

# Displays virtual info prompt (virtualenv/rvm)
function virtual_prompt_info() {
    local python_venv; _omb_prompt_get_python_venv
    local ruby_env; _omb_prompt_get_ruby_env
    local virtual_prompt=""

    local prefix=${VIRTUAL_THEME_PROMPT_PREFIX}
    local suffix=${VIRTUAL_THEME_PROMPT_SUFFIX}

    # If no virtual info, just return
    [[ $python_venv$ruby_env ]] || return

    # If virtual_env info present, append to prompt
    [[ $python_venv ]] && virtual_prompt="virtualenv: ${VE_COLOR}$python_venv${DEFAULT_COLOR}"

    if [[ $ruby_env ]]; then
        virtual_prompt="${virtual_prompt:+$virtual_prompt, }rvm: ${RVM_COLOR}$ruby_env${DEFAULT_COLOR}"
    fi
    echo -e "$prefix$virtual_prompt$suffix"
}

# Parse git info
function git_prompt_info() {
    if [[ -n $(_omb_prompt_git status -s 2> /dev/null |grep -v ^# |grep -v "working directory clean") ]]; then
        local state=${GIT_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
        local state=${GIT_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    local prefix=${GIT_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    local suffix=${GIT_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
    local ref=$(_omb_prompt_git symbolic-ref HEAD 2> /dev/null) || return
    local commit_id=$(_omb_prompt_git rev-parse HEAD 2>/dev/null) || return

    echo -e "$prefix${REF_COLOR}${ref#refs/heads/}${DEFAULT_COLOR}:${commit_id:0:$MAX_GIT_HEX_LENGTH}$state$suffix"
}

# Parse hg info
function hg_prompt_info() {
    if [[ -n $(command hg status 2> /dev/null) ]]; then
        local state=${HG_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
        local state=${HG_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    local prefix=${HG_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    local suffix=${HG_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
    local branch=$(command hg summary 2> /dev/null | grep branch | awk '{print $2}')
    local changeset=$(command hg summary 2> /dev/null | grep parent | awk '{print $2}')

    echo -e "$prefix${REF_COLOR}${branch}${DEFAULT_COLOR}:${changeset#*:}$state$suffix"
}

# Parse svn info
function svn_prompt_info() {
    if [[ -n $(command svn status --ignore-externals -q 2> /dev/null) ]]; then
        local state=${SVN_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
        local state=${SVN_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    local prefix=${SVN_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    local suffix=${SVN_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
    local ref=$(command svn info 2> /dev/null | awk -F/ '/^URL:/ { for (i=0; i<=NF; i++) { if ($i == "branches" || $i == "tags" ) { print $(i+1); break }; if ($i == "trunk") { print $i; break } } }') || return
    [[ -z $ref ]] && return

    local revision=$(command svn info 2> /dev/null | sed -ne 's#^Revision: ##p' )

    echo -e "$prefix${REF_COLOR}$ref${DEFAULT_COLOR}:$revision$state$suffix"
}

# Displays last X characters of pwd
function limited_pwd() {

    # Replace $HOME with ~ if possible
    local RELATIVE_PWD=${PWD/#$HOME/\~}

    local offset=$((${#RELATIVE_PWD}-MAX_PWD_LENGTH))

    if ((offset > 0)); then
        local truncated_symbol="..."
        local TRUNCATED_PWD=${RELATIVE_PWD:$offset:$MAX_PWD_LENGTH}
        echo -e "${truncated_symbol}/${TRUNCATED_PWD#*/}"
    else
        echo -e "${RELATIVE_PWD}"
    fi
}

# Displays the current prompt
function _omb_theme_PROMPT_COMMAND() {
    local UC=$USER_COLOR
    ((UID == 0)) && UC=$SUPERUSER_COLOR

    if [[ $VIRTUAL_PROMPT_ENABLED == 1 ]]; then
        PS1="$(scm_char) ${UC}\u ${DEFAULT_COLOR}at ${MACHINE_COLOR}\h$(ip_prompt_info) ${DEFAULT_COLOR}in ${DIRECTORY_COLOR}$(limited_pwd)${DEFAULT_COLOR}$(virtual_prompt_info)$(scm_prompt_info)${_omb_prompt_reset_color} \$ "
    else
        PS1="$(scm_char) ${UC}\u ${DEFAULT_COLOR}at ${MACHINE_COLOR}\h$(ip_prompt_info) ${DEFAULT_COLOR}in ${DIRECTORY_COLOR}$(limited_pwd)${DEFAULT_COLOR}$(scm_prompt_info)${_omb_prompt_reset_color} \$ "
    fi
    PS2='> '
    PS4='+ '
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
