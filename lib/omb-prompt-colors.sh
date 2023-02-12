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

function _omb_prompt_color_initialize {
  _omb_prompt_normal='\[\e[0m\]'
  _omb_prompt_reset_color='\[\e[39m\]'

  # used by themes/gallifrey
  _omb_prompt_bold='\[\e[1m\]'

  local -a normal_colors=(black brown green olive navy purple teal silver)
  local -a bright_colors=(gray red lime yellow blue magenta cyan white)

  local bright_fg_prefix=9 bright_bg_prefix=10
  ((_omb_term_colors >= 16)) || bright_fg_prefix=3 bright_bg_prefix=4

  local index
  for ((index = 0; index < 8; index++)); do
    printf -v "_omb_prompt_${normal_colors[index]}" %s '\[\e[0;3'"$index"'m\]'
    printf -v "_omb_prompt_bold_${normal_colors[index]}" %s '\[\e[3'"$index"';1m\]'
    printf -v "_omb_prompt_underline_${normal_colors[index]}" %s '\[\e[3'"$index"';4m\]'
    printf -v "_omb_prompt_background_${normal_colors[index]}" %s '\[\e[4'"$index"'m\]'
    printf -v "_omb_prompt_${bright_colors[index]}" %s '\[\e[0;'"$bright_fg_prefix$index"'m\]'
    printf -v "_omb_prompt_bold_${bright_colors[index]}" %s '\[\e['"$bright_fg_prefix$index"';1m\]'
    printf -v "_omb_prompt_underline_${bright_colors[index]}" %s '\[\e['"$bright_fg_prefix$index"';4m\]'
    printf -v "_omb_prompt_background_${bright_colors[index]}" %s '\[\e['"$bright_bg_prefix$index"'m\]'
  done
}
_omb_prompt_color_initialize


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
