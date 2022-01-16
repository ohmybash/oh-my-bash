#! bash oh-my-bash.module

function __ {
  echo "$@"
}

function __make_ansi {
  next=$1; shift
  echo "\[\e[$(__$next $@)m\]"
}

function __make_echo {
  next=$1; shift
  echo "\033[$(__$next $@)m"
}


function __reset {
  next=$1; shift
  out="$(__$next $@)"
  echo "0${out:+;${out}}"
}

function __bold {
  next=$1; shift
  out="$(__$next $@)"
  echo "${out:+${out};}1"
}

function __faint {
  next=$1; shift
  out="$(__$next $@)"
  echo "${out:+${out};}2"
}

function __italic {
  next=$1; shift
  out="$(__$next $@)"
  echo "${out:+${out};}3"
}

function __underline {
  next=$1; shift
  out="$(__$next $@)"
  echo "${out:+${out};}4"
}

function __negative {
  next=$1; shift
  out="$(__$next $@)"
  echo "${out:+${out};}7"
}

function __crossed {
  next=$1; shift
  out="$(__$next $@)"
  echo "${out:+${out};}8"
}


function __color_normal_fg {
  echo "3$1"
}

function __color_normal_bg {
  echo "4$1"
}

function __color_bright_fg {
  echo "9$1"
}

function __color_bright_bg {
  echo "10$1"
}


function __color_black   {
  echo "0"
}

function __color_red   {
  echo "1"
}

function __color_green   {
  echo "2"
}

function __color_yellow  {
  echo "3"
}

function __color_blue  {
  echo "4"
}

function __color_magenta {
  echo "5"
}

function __color_cyan  {
  echo "6"
}

function __color_white   {
  echo "7"
}

function __color_rgb {
  r=$1 && g=$2 && b=$3
  [[ r == g && g == b ]] && echo $(( $r / 11 + 232 )) && return # gray range above 232
  echo "8;5;$(( ($r * 36  + $b * 6 + $g) / 51 + 16 ))"
}

function __color {
  color=$1; shift
  case "$1" in
    fg|bg) side="$1"; shift ;;
    *) side=fg;;
  esac
  case "$1" in
    normal|bright) mode="$1"; shift;;
    *) mode=normal;;
  esac
  [[ $color == "rgb" ]] && rgb="$1 $2 $3"; shift 3

  next=$1; shift
  out="$(__$next $@)"
  echo "$(__color_${mode}_${side} $(__color_${color} $rgb))${out:+;${out}}"
}


function __black   {
  echo "$(__color black $@)"
}

function __red   {
  echo "$(__color red $@)"
}

function __green   {
  echo "$(__color green $@)"
}

function __yellow  {
  echo "$(__color yellow $@)"
}

function __blue  {
  echo "$(__color blue $@)"
}

function __magenta {
  echo "$(__color magenta $@)"
}

function __cyan  {
  echo "$(__color cyan $@)"
}

function __white   {
  echo "$(__color white $@)"
}

function __rgb {
  echo "$(__color rgb $@)"
}


function __color_parse {
  next=$1; shift
  echo "$(__$next $@)"
}

function color {
  echo "$(__color_parse make_ansi $@)"
}

function echo_color {
  echo "$(__color_parse make_echo $@)"
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
