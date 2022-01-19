#! bash oh-my-bash.module

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

# already defined in lib/omb-deprecated.sh
# @var _omb_prompt_red
# @var _omb_prompt_green
# @var _omb_prompt_yellow
# @var _omb_prompt_blue
# @var _omb_prompt_magenta
_omb_prompt_black='\[\e[0;30m\]'
_omb_prompt_cyan='\[\e[0;36m\]'
_omb_prompt_white='\[\e[0;37m\]'
_omb_prompt_orange='\[\e[0;91m\]'

_omb_prompt_bold_black='\[\e[30;1m\]'
_omb_prompt_bold_red='\[\e[31;1m\]'
_omb_prompt_bold_green='\[\e[32;1m\]'
_omb_prompt_bold_yellow='\[\e[33;1m\]'
_omb_prompt_bold_blue='\[\e[34;1m\]'
_omb_prompt_bold_magenta='\[\e[35;1m\]'
_omb_prompt_bold_cyan='\[\e[36;1m\]'
_omb_prompt_bold_white='\[\e[37;1m\]'
_omb_prompt_bold_orange='\[\e[91;1m\]'

_omb_prompt_underline_black='\[\e[30;4m\]'
_omb_prompt_underline_red='\[\e[31;4m\]'
_omb_prompt_underline_green='\[\e[32;4m\]'
_omb_prompt_underline_yellow='\[\e[33;4m\]'
_omb_prompt_underline_blue='\[\e[34;4m\]'
_omb_prompt_underline_magenta='\[\e[35;4m\]'
_omb_prompt_underline_cyan='\[\e[36;4m\]'
_omb_prompt_underline_white='\[\e[37;4m\]'
_omb_prompt_underline_orange='\[\e[91;4m\]'

_omb_prompt_background_black='\[\e[40m\]'
_omb_prompt_background_red='\[\e[41m\]'
_omb_prompt_background_green='\[\e[42m\]'
_omb_prompt_background_yellow='\[\e[43m\]'
_omb_prompt_background_blue='\[\e[44m\]'
_omb_prompt_background_magenta='\[\e[45m\]'
_omb_prompt_background_cyan='\[\e[46m\]'
_omb_prompt_background_white='\[\e[47;1m\]'
_omb_prompt_background_orange='\[\e[101m\]'

_omb_prompt_normal='\[\e[0m\]'
_omb_prompt_reset_color='\[\e[39m\]'

# These colors are meant to be used with `echo -e`

# These variables are defined in lib/utils.sh
#
# _omb_term_black=$'\e[0;30m'
# _omb_term_red=$'\e[0;31m'
# _omb_term_green=$'\e[0;32m'
# _omb_term_yellow=$'\e[0;33m'
# _omb_term_blue=$'\e[0;34m'
# _omb_term_magenta=$'\e[0;35m'
# _omb_term_cyan=$'\e[0;36m'
# _omb_term_white=$'\e[0;37;1m'
# _omb_term_orange=$'\e[0;91m'

_omb_term_bold_black=$'\e[30;1m'
_omb_term_bold_red=$'\e[31;1m'
_omb_term_bold_green=$'\e[32;1m'
_omb_term_bold_yellow=$'\e[33;1m'
_omb_term_bold_blue=$'\e[34;1m'
_omb_term_bold_magenta=$'\e[35;1m'
_omb_term_bold_cyan=$'\e[36;1m'
_omb_term_bold_white=$'\e[37;1m'
_omb_term_bold_orange=$'\e[91;1m'

_omb_term_underline_black=$'\e[30;4m'
_omb_term_underline_red=$'\e[31;4m'
_omb_term_underline_green=$'\e[32;4m'
_omb_term_underline_yellow=$'\e[33;4m'
_omb_term_underline_blue=$'\e[34;4m'
_omb_term_underline_magenta=$'\e[35;4m'
_omb_term_underline_cyan=$'\e[36;4m'
_omb_term_underline_white=$'\e[37;4m'
_omb_term_underline_orange=$'\e[91;4m'

_omb_term_background_black=$'\e[40m'
_omb_term_background_red=$'\e[41m'
_omb_term_background_green=$'\e[42m'
_omb_term_background_yellow=$'\e[43m'
_omb_term_background_blue=$'\e[44m'
_omb_term_background_magenta=$'\e[45m'
_omb_term_background_cyan=$'\e[46m'
_omb_term_background_white=$'\e[47;1m'
_omb_term_background_orange=$'\e[101m'

_omb_term_normal=$'\e[0m'
_omb_term_reset_color=$'\e[39m'

_omb_deprecate_function 20000 color      _omb_theme_color_prompt
_omb_deprecate_function 20000 echo_color _omb_theme_color_echo

_omb_deprecate_const 20000 black             "$_omb_prompt_black"              "Please use '_omb_prompt_black'."
_omb_deprecate_const 20000 cyan              "$_omb_prompt_cyan"               "Please use '_omb_prompt_cyan'."
_omb_deprecate_const 20000 white             "$_omb_prompt_white"              "Please use '_omb_prompt_white'."
_omb_deprecate_const 20000 orange            "$_omb_prompt_orange"             "Please use '_omb_prompt_orange'."

_omb_deprecate_const 20000 bold_black        "$_omb_prompt_bold_black"         "Please use '_omb_prompt_bold_black'."
_omb_deprecate_const 20000 bold_red          "$_omb_prompt_bold_red"           "Please use '_omb_prompt_bold_red'."
_omb_deprecate_const 20000 bold_green        "$_omb_prompt_bold_green"         "Please use '_omb_prompt_bold_green'."
_omb_deprecate_const 20000 bold_yellow       "$_omb_prompt_bold_yellow"        "Please use '_omb_prompt_bold_yellow'."
_omb_deprecate_const 20000 bold_blue         "$_omb_prompt_bold_blue"          "Please use '_omb_prompt_bold_blue'."
_omb_deprecate_const 20000 bold_purple       "$_omb_prompt_bold_magenta"       "Please use '_omb_prompt_bold_magenta'."
_omb_deprecate_const 20000 bold_cyan         "$_omb_prompt_bold_cyan"          "Please use '_omb_prompt_bold_cyan'."
_omb_deprecate_const 20000 bold_white        "$_omb_prompt_bold_white"         "Please use '_omb_prompt_bold_white'."
_omb_deprecate_const 20000 bold_orange       "$_omb_prompt_bold_orange"        "Please use '_omb_prompt_bold_orange'."

_omb_deprecate_const 20000 underline_black   "$_omb_prompt_underline_black"    "Please use '_omb_prompt_underline_black'."
_omb_deprecate_const 20000 underline_red     "$_omb_prompt_underline_red"      "Please use '_omb_prompt_underline_red'."
_omb_deprecate_const 20000 underline_green   "$_omb_prompt_underline_green"    "Please use '_omb_prompt_underline_green'."
_omb_deprecate_const 20000 underline_yellow  "$_omb_prompt_underline_yellow"   "Please use '_omb_prompt_underline_yellow'."
_omb_deprecate_const 20000 underline_blue    "$_omb_prompt_underline_blue"     "Please use '_omb_prompt_underline_blue'."
_omb_deprecate_const 20000 underline_purple  "$_omb_prompt_underline_magenta"  "Please use '_omb_prompt_underline_magenta'."
_omb_deprecate_const 20000 underline_cyan    "$_omb_prompt_underline_cyan"     "Please use '_omb_prompt_underline_cyan'."
_omb_deprecate_const 20000 underline_white   "$_omb_prompt_underline_white"    "Please use '_omb_prompt_underline_white'."
_omb_deprecate_const 20000 underline_orange  "$_omb_prompt_underline_orange"   "Please use '_omb_prompt_underline_orange'."

_omb_deprecate_const 20000 background_black  "$_omb_prompt_background_black"   "Please use '_omb_prompt_background_black'."
_omb_deprecate_const 20000 background_red    "$_omb_prompt_background_red"     "Please use '_omb_prompt_background_red'."
_omb_deprecate_const 20000 background_green  "$_omb_prompt_background_green"   "Please use '_omb_prompt_background_green'."
_omb_deprecate_const 20000 background_yellow "$_omb_prompt_background_yellow"  "Please use '_omb_prompt_background_yellow'."
_omb_deprecate_const 20000 background_blue   "$_omb_prompt_background_blue"    "Please use '_omb_prompt_background_blue'."
_omb_deprecate_const 20000 background_purple "$_omb_prompt_background_magenta" "Please use '_omb_prompt_background_magenta'."
_omb_deprecate_const 20000 background_cyan   "$_omb_prompt_background_cyan"    "Please use '_omb_prompt_background_cyan'."
_omb_deprecate_const 20000 background_white  "$_omb_prompt_background_white"   "Please use '_omb_prompt_background_white'."
_omb_deprecate_const 20000 background_orange "$_omb_prompt_background_orange"  "Please use '_omb_prompt_background_orange'."

_omb_deprecate_const 20000 normal            "$_omb_prompt_normal"             "Please use '_omb_prompt_normal'."
_omb_deprecate_const 20000 reset_color       "$_omb_prompt_reset_color"        "Please use '_omb_prompt_reset_color'."

_omb_deprecate_const 20000 echo_black             "$_omb_term_black"              "Please use '_omb_term_black'."
_omb_deprecate_const 20000 echo_red               "$_omb_term_red"                "Please use '_omb_term_red'."
_omb_deprecate_const 20000 echo_green             "$_omb_term_green"              "Please use '_omb_term_green'."
_omb_deprecate_const 20000 echo_yellow            "$_omb_term_yellow"             "Please use '_omb_term_yellow'."
_omb_deprecate_const 20000 echo_blue              "$_omb_term_blue"               "Please use '_omb_term_blue'."
_omb_deprecate_const 20000 echo_purple            "$_omb_term_magenta"            "Please use '_omb_term_magenta'."
_omb_deprecate_const 20000 echo_cyan              "$_omb_term_cyan"               "Please use '_omb_term_cyan'."
_omb_deprecate_const 20000 echo_white             "$_omb_term_white"              "Please use '_omb_term_white'."
_omb_deprecate_const 20000 echo_orange            "$_omb_term_orange"             "Please use '_omb_term_orange'."

_omb_deprecate_const 20000 echo_bold_black        "$_omb_term_bold_black"         "Please use '_omb_term_bold_black'."
_omb_deprecate_const 20000 echo_bold_red          "$_omb_term_bold_red"           "Please use '_omb_term_bold_red'."
_omb_deprecate_const 20000 echo_bold_green        "$_omb_term_bold_green"         "Please use '_omb_term_bold_green'."
_omb_deprecate_const 20000 echo_bold_yellow       "$_omb_term_bold_yellow"        "Please use '_omb_term_bold_yellow'."
_omb_deprecate_const 20000 echo_bold_blue         "$_omb_term_bold_blue"          "Please use '_omb_term_bold_blue'."
_omb_deprecate_const 20000 echo_bold_purple       "$_omb_term_bold_magenta"       "Please use '_omb_term_bold_magenta'."
_omb_deprecate_const 20000 echo_bold_cyan         "$_omb_term_bold_cyan"          "Please use '_omb_term_bold_cyan'."
_omb_deprecate_const 20000 echo_bold_white        "$_omb_term_bold_white"         "Please use '_omb_term_bold_white'."
_omb_deprecate_const 20000 echo_bold_orange       "$_omb_term_bold_orange"        "Please use '_omb_term_bold_orange'."

_omb_deprecate_const 20000 echo_underline_black   "$_omb_term_underline_black"    "Please use '_omb_term_underline_black'."
_omb_deprecate_const 20000 echo_underline_red     "$_omb_term_underline_red"      "Please use '_omb_term_underline_red'."
_omb_deprecate_const 20000 echo_underline_green   "$_omb_term_underline_green"    "Please use '_omb_term_underline_green'."
_omb_deprecate_const 20000 echo_underline_yellow  "$_omb_term_underline_yellow"   "Please use '_omb_term_underline_yellow'."
_omb_deprecate_const 20000 echo_underline_blue    "$_omb_term_underline_blue"     "Please use '_omb_term_underline_blue'."
_omb_deprecate_const 20000 echo_underline_purple  "$_omb_term_underline_magenta"  "Please use '_omb_term_underline_magenta'."
_omb_deprecate_const 20000 echo_underline_cyan    "$_omb_term_underline_cyan"     "Please use '_omb_term_underline_cyan'."
_omb_deprecate_const 20000 echo_underline_white   "$_omb_term_underline_white"    "Please use '_omb_term_underline_white'."
_omb_deprecate_const 20000 echo_underline_orange  "$_omb_term_underline_orange"   "Please use '_omb_term_underline_orange'."

_omb_deprecate_const 20000 echo_background_black  "$_omb_term_background_black"   "Please use '_omb_term_background_black'."
_omb_deprecate_const 20000 echo_background_red    "$_omb_term_background_red"     "Please use '_omb_term_background_red'."
_omb_deprecate_const 20000 echo_background_green  "$_omb_term_background_green"   "Please use '_omb_term_background_green'."
_omb_deprecate_const 20000 echo_background_yellow "$_omb_term_background_yellow"  "Please use '_omb_term_background_yellow'."
_omb_deprecate_const 20000 echo_background_blue   "$_omb_term_background_blue"    "Please use '_omb_term_background_blue'."
_omb_deprecate_const 20000 echo_background_purple "$_omb_term_background_magenta" "Please use '_omb_term_background_magenta'."
_omb_deprecate_const 20000 echo_background_cyan   "$_omb_term_background_cyan"    "Please use '_omb_term_background_cyan'."
_omb_deprecate_const 20000 echo_background_white  "$_omb_term_background_white"   "Please use '_omb_term_background_white'."
_omb_deprecate_const 20000 echo_background_orange "$_omb_term_background_orange"  "Please use '_omb_term_background_orange'."

_omb_deprecate_const 20000 echo_normal            "$_omb_term_normal"             "Please use '_omb_term_normal'."
_omb_deprecate_const 20000 echo_reset_color       "$_omb_term_reset_color"        "Please use '_omb_term_reset_color'."
