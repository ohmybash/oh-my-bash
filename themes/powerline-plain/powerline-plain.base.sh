#! bash oh-my-bash.module

source "$OSH/themes/powerline/powerline.base.sh"

function __powerline_left_segment {
  local OLD_IFS="${IFS}"; IFS="|"
  local params=( $1 )
  IFS="${OLD_IFS}"
  local text_color=${params[2]:-"-"}

  LEFT_PROMPT+="${separator}$(set_color ${text_color} ${params[1]}) ${params[0]} ${_omb_prompt_normal}"
  LAST_SEGMENT_COLOR=${params[1]}
}

function __powerline_prompt_command {
  local last_status="$?" ## always the first

  LEFT_PROMPT=""

  ## left prompt ##
  for segment in $POWERLINE_PROMPT; do
    local info="$(__powerline_${segment}_prompt)"
    [[ -n "${info}" ]] && __powerline_left_segment "${info}"
  done
  [[ "${last_status}" -ne 0 ]] && __powerline_left_segment $(__powerline_last_status_prompt ${last_status})
  [[ -n "${LEFT_PROMPT}" ]] && LEFT_PROMPT+="$(set_color ${LAST_SEGMENT_COLOR} -) ${_omb_prompt_normal}"

  PS1="${LEFT_PROMPT} "

  ## cleanup ##
  unset LEFT_PROMPT
}
