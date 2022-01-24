#! bash oh-my-bash.module
#
# 2022-01-20 Koichi Murase: renamed from "themes/colours.theme.sh" to "lib/omb-prompt-colors.sh"

_omb_module_require lib:omb-deprecate

function _omb_theme__construct_sgr {
  out=
  local reset=
  while (($#)); do
    local next=$1; shift
    case $next in
    reset)     reset=0 ;;
    bold)      out=${out:+$out;}1 ;;
    faint)     out=${out:+$out;}2 ;;
    italic)    out=${out:+$out;}3 ;;
    underline) out=${out:+$out;}4 ;;
    negative)  out=${out:+$out;}7 ;;
    crossed)   out=${out:+$out;}8 ;;
    color)
      local color=$1; shift

      local side=fg mode=normal
      case $1 in
      fg | bg) side=$1; shift ;;
      esac
      case $1 in
      normal | bright) mode=$1; shift ;;
      esac

      local prefix=3
      case $side:$mode in
      fg:normal) prefix=3  ;;
      bg:normal) prefix=4  ;;
      fg:bright) prefix=9  ;;
      bg:bright) prefix=10 ;;
      esac

      case $color in
      black)   color=0 ;;
      red)     color=1 ;;
      green)   color=2 ;;
      yellow)  color=3 ;;
      blue)    color=4 ;;
      magenta) color=5 ;;
      cyan)    color=6 ;;
      white)   color=7 ;;
      rgb)
        local r=$1 g=$2 b=$3; shift 3
        if ((r == g && g == b)); then
          # gray range above 232
          color=$((232 + r / 11))
        else
          color="8;5;$(((r * 36  + b * 6 + g) / 51 + 16))"
        fi ;;
      *) printf '%s\n' "_omb_theme_color: unknown color '$color'" >&2
         continue ;;
      esac
      out=${out:+$out;}$prefix$color ;;
    '')
      out="${out:+$out;}$*" ;;
    *)
      printf '%s\n' "_omb_theme_color: unknown token '$next'" >&2 ;;
    esac
  done

  if [[ $reset ]]; then
    out=$reset${out:+;$out}
  fi
}

function _omb_theme_color_prompt {
  local out
  _omb_theme__construct_sgr "$@"
  echo "\[\e[${out}m\]"
}

function _omb_theme_color_echo {
  local out
  _omb_theme__construct_sgr "$@"
  echo "\033[${out}m"
}

_omb_prompt_brown='\[\e[0;31m\]'
_omb_prompt_green='\[\e[0;32m\]'
_omb_prompt_olive='\[\e[0;33m\]'
_omb_prompt_navy='\[\e[0;34m\]'
_omb_prompt_purple='\[\e[0;35m\]'
_omb_prompt_black='\[\e[0;30m\]'
_omb_prompt_teal='\[\e[0;36m\]'
_omb_prompt_white='\[\e[0;37m\]'
_omb_prompt_red='\[\e[0;91m\]'

_omb_prompt_bold_black='\[\e[30;1m\]'
_omb_prompt_bold_brown='\[\e[31;1m\]'
_omb_prompt_bold_green='\[\e[32;1m\]'
_omb_prompt_bold_olive='\[\e[33;1m\]'
_omb_prompt_bold_navy='\[\e[34;1m\]'
_omb_prompt_bold_purple='\[\e[35;1m\]'
_omb_prompt_bold_teal='\[\e[36;1m\]'
_omb_prompt_bold_white='\[\e[37;1m\]'
_omb_prompt_bold_red='\[\e[91;1m\]'

_omb_prompt_underline_black='\[\e[30;4m\]'
_omb_prompt_underline_brown='\[\e[31;4m\]'
_omb_prompt_underline_green='\[\e[32;4m\]'
_omb_prompt_underline_olive='\[\e[33;4m\]'
_omb_prompt_underline_navy='\[\e[34;4m\]'
_omb_prompt_underline_purple='\[\e[35;4m\]'
_omb_prompt_underline_teal='\[\e[36;4m\]'
_omb_prompt_underline_white='\[\e[37;4m\]'
_omb_prompt_underline_red='\[\e[91;4m\]'

_omb_prompt_background_black='\[\e[40m\]'
_omb_prompt_background_brown='\[\e[41m\]'
_omb_prompt_background_green='\[\e[42m\]'
_omb_prompt_background_olive='\[\e[43m\]'
_omb_prompt_background_navy='\[\e[44m\]'
_omb_prompt_background_purple='\[\e[45m\]'
_omb_prompt_background_teal='\[\e[46m\]'
_omb_prompt_background_white='\[\e[47;1m\]'
_omb_prompt_background_red='\[\e[101m\]'

_omb_prompt_normal='\[\e[0m\]'
_omb_prompt_reset_color='\[\e[39m\]'

# These colors are intended to be used with `echo`

# These variables are defined in "lib/utils.sh"
# - _omb_term_{,_bold,_underline,_background}{<basic8>,red,white,violet}

_omb_term_normal=$'\e[0m'
_omb_term_reset_color=$'\e[39m'

# used by themes/gallifrey
_omb_prompt_bold='\[\e[1m\]'

_omb_deprecate_function 20000 color      _omb_theme_color_prompt
_omb_deprecate_function 20000 echo_color _omb_theme_color_echo

_omb_deprecate_const 20000 black             "$_omb_prompt_black"             "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_black}"
_omb_deprecate_const 20000 cyan              "$_omb_prompt_teal"              "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_teal}"
_omb_deprecate_const 20000 white             "$_omb_prompt_white"             "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_white}"
_omb_deprecate_const 20000 orange            "$_omb_prompt_red"               "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_red}"

_omb_deprecate_const 20000 bold_black        "$_omb_prompt_bold_black"        "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_black}"
_omb_deprecate_const 20000 bold_red          "$_omb_prompt_bold_brown"        "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_brown}"
_omb_deprecate_const 20000 bold_green        "$_omb_prompt_bold_green"        "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_green}"
_omb_deprecate_const 20000 bold_yellow       "$_omb_prompt_bold_olive"        "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_olive}"
_omb_deprecate_const 20000 bold_blue         "$_omb_prompt_bold_navy"         "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_navy}"
_omb_deprecate_const 20000 bold_purple       "$_omb_prompt_bold_purple"       "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_purple}"
_omb_deprecate_const 20000 bold_cyan         "$_omb_prompt_bold_teal"         "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_teal}"
_omb_deprecate_const 20000 bold_white        "$_omb_prompt_bold_white"        "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_white}"
_omb_deprecate_const 20000 bold_orange       "$_omb_prompt_bold_red"          "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_red}"

_omb_deprecate_const 20000 underline_black   "$_omb_prompt_underline_black"   "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_underline_black}"
_omb_deprecate_const 20000 underline_red     "$_omb_prompt_underline_brown"   "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_underline_brown}"
_omb_deprecate_const 20000 underline_green   "$_omb_prompt_underline_green"   "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_underline_green}"
_omb_deprecate_const 20000 underline_yellow  "$_omb_prompt_underline_olive"   "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_underline_olive}"
_omb_deprecate_const 20000 underline_blue    "$_omb_prompt_underline_navy"    "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_underline_navy}"
_omb_deprecate_const 20000 underline_purple  "$_omb_prompt_underline_purple"  "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_underline_purple}"
_omb_deprecate_const 20000 underline_cyan    "$_omb_prompt_underline_teal"    "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_underline_teal}"
_omb_deprecate_const 20000 underline_white   "$_omb_prompt_underline_white"   "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_underline_white}"
_omb_deprecate_const 20000 underline_orange  "$_omb_prompt_underline_red"     "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_underline_red}"

_omb_deprecate_const 20000 background_black  "$_omb_prompt_background_black"  "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_background_black}"
_omb_deprecate_const 20000 background_red    "$_omb_prompt_background_brown"  "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_background_brown}"
_omb_deprecate_const 20000 background_green  "$_omb_prompt_background_green"  "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_background_green}"
_omb_deprecate_const 20000 background_yellow "$_omb_prompt_background_olive"  "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_background_olive}"
_omb_deprecate_const 20000 background_blue   "$_omb_prompt_background_navy"   "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_background_navy}"
_omb_deprecate_const 20000 background_purple "$_omb_prompt_background_purple" "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_background_purple}"
_omb_deprecate_const 20000 background_cyan   "$_omb_prompt_background_teal"   "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_background_teal}"
_omb_deprecate_const 20000 background_white  "$_omb_prompt_background_white"  "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_background_white}"
_omb_deprecate_const 20000 background_orange "$_omb_prompt_background_red"    "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_background_red}"

_omb_deprecate_const 20000 normal            "$_omb_prompt_normal"            "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_normal}"
_omb_deprecate_const 20000 reset_color       "$_omb_prompt_reset_color"       "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_reset_color}"

_omb_deprecate_const 20000 echo_black             "$_omb_term_black"             "${_omb_deprecate_msg_please_use/'%s'/_omb_term_black}"
_omb_deprecate_const 20000 echo_red               "$_omb_term_brown"             "${_omb_deprecate_msg_please_use/'%s'/_omb_term_brown}"
_omb_deprecate_const 20000 echo_green             "$_omb_term_green"             "${_omb_deprecate_msg_please_use/'%s'/_omb_term_green}"
_omb_deprecate_const 20000 echo_yellow            "$_omb_term_olive"             "${_omb_deprecate_msg_please_use/'%s'/_omb_term_olive}"
_omb_deprecate_const 20000 echo_blue              "$_omb_term_navy"              "${_omb_deprecate_msg_please_use/'%s'/_omb_term_navy}"
_omb_deprecate_const 20000 echo_purple            "$_omb_term_purple"            "${_omb_deprecate_msg_please_use/'%s'/_omb_term_purple}"
_omb_deprecate_const 20000 echo_cyan              "$_omb_term_teal"              "${_omb_deprecate_msg_please_use/'%s'/_omb_term_teal}"
_omb_deprecate_const 20000 echo_white             "$_omb_term_white"             "${_omb_deprecate_msg_please_use/'%s'/_omb_term_white}"
_omb_deprecate_const 20000 echo_orange            "$_omb_term_red"               "${_omb_deprecate_msg_please_use/'%s'/_omb_term_red}"

_omb_deprecate_const 20000 echo_bold_black        "$_omb_term_bold_black"        "${_omb_deprecate_msg_please_use/'%s'/_omb_term_bold_black}"
_omb_deprecate_const 20000 echo_bold_red          "$_omb_term_bold_brown"        "${_omb_deprecate_msg_please_use/'%s'/_omb_term_bold_brown}"
_omb_deprecate_const 20000 echo_bold_green        "$_omb_term_bold_green"        "${_omb_deprecate_msg_please_use/'%s'/_omb_term_bold_green}"
_omb_deprecate_const 20000 echo_bold_yellow       "$_omb_term_bold_olive"        "${_omb_deprecate_msg_please_use/'%s'/_omb_term_bold_olive}"
_omb_deprecate_const 20000 echo_bold_blue         "$_omb_term_bold_navy"         "${_omb_deprecate_msg_please_use/'%s'/_omb_term_bold_navy}"
_omb_deprecate_const 20000 echo_bold_purple       "$_omb_term_bold_purple"       "${_omb_deprecate_msg_please_use/'%s'/_omb_term_bold_purple}"
_omb_deprecate_const 20000 echo_bold_cyan         "$_omb_term_bold_teal"         "${_omb_deprecate_msg_please_use/'%s'/_omb_term_bold_teal}"
_omb_deprecate_const 20000 echo_bold_white        "$_omb_term_bold_white"        "${_omb_deprecate_msg_please_use/'%s'/_omb_term_bold_white}"
_omb_deprecate_const 20000 echo_bold_orange       "$_omb_term_bold_red"          "${_omb_deprecate_msg_please_use/'%s'/_omb_term_bold_red}"

_omb_deprecate_const 20000 echo_underline_black   "$_omb_term_underline_black"   "${_omb_deprecate_msg_please_use/'%s'/_omb_term_underline_black}"
_omb_deprecate_const 20000 echo_underline_red     "$_omb_term_underline_brown"   "${_omb_deprecate_msg_please_use/'%s'/_omb_term_underline_brown}"
_omb_deprecate_const 20000 echo_underline_green   "$_omb_term_underline_green"   "${_omb_deprecate_msg_please_use/'%s'/_omb_term_underline_green}"
_omb_deprecate_const 20000 echo_underline_yellow  "$_omb_term_underline_olive"   "${_omb_deprecate_msg_please_use/'%s'/_omb_term_underline_olive}"
_omb_deprecate_const 20000 echo_underline_blue    "$_omb_term_underline_navy"    "${_omb_deprecate_msg_please_use/'%s'/_omb_term_underline_navy}"
_omb_deprecate_const 20000 echo_underline_purple  "$_omb_term_underline_purple"  "${_omb_deprecate_msg_please_use/'%s'/_omb_term_underline_purple}"
_omb_deprecate_const 20000 echo_underline_cyan    "$_omb_term_underline_teal"    "${_omb_deprecate_msg_please_use/'%s'/_omb_term_underline_teal}"
_omb_deprecate_const 20000 echo_underline_white   "$_omb_term_underline_white"   "${_omb_deprecate_msg_please_use/'%s'/_omb_term_underline_white}"
_omb_deprecate_const 20000 echo_underline_orange  "$_omb_term_underline_red"     "${_omb_deprecate_msg_please_use/'%s'/_omb_term_underline_red}"

_omb_deprecate_const 20000 echo_background_black  "$_omb_term_background_black"  "${_omb_deprecate_msg_please_use/'%s'/_omb_term_background_black}"
_omb_deprecate_const 20000 echo_background_red    "$_omb_term_background_brown"  "${_omb_deprecate_msg_please_use/'%s'/_omb_term_background_brown}"
_omb_deprecate_const 20000 echo_background_green  "$_omb_term_background_green"  "${_omb_deprecate_msg_please_use/'%s'/_omb_term_background_green}"
_omb_deprecate_const 20000 echo_background_yellow "$_omb_term_background_olive"  "${_omb_deprecate_msg_please_use/'%s'/_omb_term_background_olive}"
_omb_deprecate_const 20000 echo_background_blue   "$_omb_term_background_navy"   "${_omb_deprecate_msg_please_use/'%s'/_omb_term_background_navy}"
_omb_deprecate_const 20000 echo_background_purple "$_omb_term_background_purple" "${_omb_deprecate_msg_please_use/'%s'/_omb_term_background_purple}"
_omb_deprecate_const 20000 echo_background_cyan   "$_omb_term_background_teal"   "${_omb_deprecate_msg_please_use/'%s'/_omb_term_background_teal}"
_omb_deprecate_const 20000 echo_background_white  "$_omb_term_background_white"  "${_omb_deprecate_msg_please_use/'%s'/_omb_term_background_white}"
_omb_deprecate_const 20000 echo_background_orange "$_omb_term_background_red"    "${_omb_deprecate_msg_please_use/'%s'/_omb_term_background_red}"

_omb_deprecate_const 20000 echo_normal            "$_omb_term_normal"            "${_omb_deprecate_msg_please_use/'%s'/_omb_term_normal}"
_omb_deprecate_const 20000 echo_reset_color       "$_omb_term_reset_color"       "${_omb_deprecate_msg_please_use/'%s'/_omb_term_reset_color}"
