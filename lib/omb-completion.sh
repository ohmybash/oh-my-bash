#! bash oh-my-bash.module
# Copyright 2023 Koichi Murase.
#
# Helper functions for completions
#

## @fn _omb_completion_reassemble_breaks exclude
##   @param[in] $1 exclude Characters to exclude from COMP_WORDSBREAKS
##   @var[out] cur[0] Current word after reassembly
##   @var[out] cur[1] Part of ${cur[0]} that was originally in previous words
##     in COMP_WORDS.
##   @arr[out] COMPREPLY This functions empties the array COMPREPLY.
function _omb_completion_reassemble_breaks {
  local exclude=$1
  local line=$COMP_LINE point=$COMP_POINT
  local breaks=${COMP_WORDBREAKS//[\"\'$exclude]}

  COMPREPLY=()
  cur=("${COMP_WORDS[COMP_CWORD]}" '')

  local word rprefix= rword=
  for word in "${COMP_WORDS[@]::COMP_CWORD+1}"; do
    local space=${line%%"$word"*}
    if [[ $space == "$line" ]]; then
      # error: COMP_LINE does not contain enough words
      return 1
    fi

    word=${word::point - ${#space}}
    if [[ $space || $rword == *["$breaks"] || $word == ["$breaks"]* ]]; then
      rprefix=
      rword=$word
    else
      rprefix=$rword
      rword+=$word
    fi

    line=${line:${#space}+${#word}}
    ((point -= ${#space} + ${#word}))
    ((point >= 0)) || break
  done

  cur=("$rword" "$rprefix")
}

## @fn _omb_completion_resolve_breaks
##   Adjust completions generated for the reassembled word
##   @var[out] cur[1] Prefix to remove set by _omb_completion_reassemble_breaks
##   @arr[out] COMPREPLY This functions empties the array COMPREPLY.
function _omb_completion_resolve_breaks {
  if [[ ${cur[1]} ]]; then
    local i
    for i in "${!COMPREPLY[@]}"; do
      if [[ ${COMPREPLY[i]} == "$cur_prefix"* ]]; then
        COMPREPLY[i]=${COMPREPLY[i]#"$cur_prefix"}
      else
        unset -v 'COMPREPLY[i]'
      fi
    done
    COMPREPLY=("${COMPREPLY[@]}")
  fi
}
