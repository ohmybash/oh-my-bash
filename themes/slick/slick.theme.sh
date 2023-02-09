#! bash oh-my-bash.module
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}✗${_omb_prompt_normal}"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
SCM_GIT_CHAR="${_omb_prompt_bold_teal}±${_omb_prompt_normal}"
SCM_SVN_CHAR="${_omb_prompt_bold_green}⑆${_omb_prompt_normal}"
SCM_HG_CHAR="${_omb_prompt_bold_brown}☿${_omb_prompt_normal}"

#Mysql Prompt
export MYSQL_PS1="(\u@\h) [\d]> "

case $TERM in
        xterm*)
        TITLEBAR="\[\033]0;\w\007\]"
        ;;
        *)
        TITLEBAR=""
        ;;
esac

PS3=">> "

function __my_rvm_ruby_version {
    local gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')
  [ "$gemset" != "" ] && gemset="@$gemset"
    local version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')
    local full="$version$gemset"
  [ "$full" != "" ] && echo "[$full]"
}

function __my_venv_prompt {
  if [ ! -z "$VIRTUAL_ENV" ]
  then
    echo "[${_omb_prompt_navy}@${_omb_prompt_normal}${VIRTUAL_ENV##*/}]"
  fi
}

function is_vim_shell {
        if [ ! -z "$VIMRUNTIME" ]
        then
                echo "[${_omb_prompt_teal}vim shell${_omb_prompt_normal}]"
        fi
}

function modern_scm_prompt {
        CHAR=$(scm_char)
        if [ $CHAR = $SCM_NONE_CHAR ]
        then
                return
        else
                echo "[$(scm_char)][$(scm_prompt_info)]"
        fi
}

function _omb_theme_PROMPT_COMMAND {

   case $HOSTNAME in
    "clappy"* ) my_ps_host="${_omb_prompt_green}\h${_omb_prompt_normal}";
            ;;
    "icekernel") my_ps_host="${_omb_prompt_brown}\h${_omb_prompt_normal}";
            ;;
    * ) my_ps_host="${_omb_prompt_green}\h${_omb_prompt_normal}";
            ;;
    esac

    my_ps_user="\[\033[01;32m\]\u\[\033[00m\]";
    my_ps_root="\[\033[01;31m\]\u\[\033[00m\]";
    my_ps_path="\[\033[01;36m\]\w\[\033[00m\]";

    # nice prompt
    case "`id -u`" in
        0) PS1="${TITLEBAR}[$my_ps_root][$my_ps_host]$(modern_scm_prompt)$(__my_rvm_ruby_version)[${_omb_prompt_teal}\w${_omb_prompt_normal}]$(is_vim_shell)
$ "
        ;;
      *) PS1="${TITLEBAR}[$my_ps_user][$my_ps_host]$(modern_scm_prompt)$(__my_rvm_ruby_version)$(__my_venv_prompt)[${_omb_prompt_teal}\w${_omb_prompt_normal}]$(is_vim_shell)
$ "
        ;;
    esac
}

PS2="> "



_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
