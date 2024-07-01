#! bash oh-my-bash.module
# aws.plugin.sh
# Author: Michael Anckaert <michael.anckaert@sinax.be>
# Based on oh-my-zsh AWS plugin
#
# command 'agp' returns the selected AWS profile (aws get profile)
# command 'asp' sets the AWS profile to use (aws set profile)
#

function agp {
  echo $AWS_PROFILE
}

function asp {
  export AWS_PROFILE=$1
}

function _aws_profiles {
  grep '\[profile' ~/.aws/config \
    | grep -v '^[[:space:]]*#' \
    | tr -d '\[\]' \
    | awk '{print $2}'
}

complete -W "$(_aws_profiles)" asp
