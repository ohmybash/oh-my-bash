#! bash oh-my-bash.module

function _omb_string_escape_prompt {
  REPLY=$1
  local specialchars='\`$'
  if [[ $REPLY == ["$specialchars"] ]]; then
    local i n=${#specialchars} a b
    for ((i=0;i<n;i++)); do
      a=${specialchars:i:1}
      b='\'$a
      REPLY=${REPLY//"$a"/"$b"}
    done
  fi
}
