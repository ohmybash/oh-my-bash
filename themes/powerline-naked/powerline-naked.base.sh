#! bash oh-my-bash.module

source "$OSH/themes/powerline/powerline.base.sh"

function __powerline_left_segment {
  local OLD_IFS="${IFS}"; IFS="|"
  local params=( $1 )
  IFS="${OLD_IFS}"
  local separator_char=""
  local separator=""
  local background_color=${params[2]:-"-"}

  if [[ "${SEGMENTS_AT_LEFT}" -gt 0 ]]; then
    separator="${separator_char}"
  fi
  LEFT_PROMPT+="${separator}$(set_color ${params[1]} ${background_color}) ${params[0]} ${_omb_prompt_normal}"
  (( SEGMENTS_AT_LEFT += 1 ))
}
