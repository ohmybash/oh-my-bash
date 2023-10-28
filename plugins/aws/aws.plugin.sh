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
  local rprompt=${RPROMPT/<aws:$(agp)>/}

  export AWS_PROFILE=$1
}
