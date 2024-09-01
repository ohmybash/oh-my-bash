#! bash oh-my-bash.module
#
# This plugin is based on the following version of the Oh-My-Zsh plugin:
# https://github.com/ohmyzsh/ohmyzsh/blame/c68ff8aeedc2b779ae42d745457ecd443e22e212/plugins/dotnet/dotnet.plugin.zsh

# bash parameter completion for the dotnet CLI was taken from the following
# source under the MIT license:
# source: https://github.com/dotnet/sdk/blob/f271b05d65e8218d3c276f417d66021692108118/scripts/register-completions.bash
# Copyright (c) .NET Foundation and Contributors
_dotnet_bash_complete()
{
  local word=${COMP_WORDS[COMP_CWORD]}

  local completions
  completions="$(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)"
  if [ $? -ne 0 ]; then
    completions=""
  fi

  COMPREPLY=( $(compgen -W "$completions" -- "$word") )
}
complete -f -F _dotnet_bash_complete dotnet


# Aliases bellow are here for backwards compatibility
# added by Shaun Tabone (https://github.com/xontab)

#Create a new .NET project or file.
alias dn='dotnet new'
#Build and run a .NET project output.
alias dr='dotnet run'
#Run unit tests using the test runner specified in a .NET project.
alias dt='dotnet test'
#Watch for source file changes and restart the dotnet command.
alias dw='dotnet watch'
#Watch for source file changes and restart the `run` command.
alias dwr='dotnet watch run'
#Watch for source file changes and restart the `test` command.
alias dwt='dotnet watch test'
#Modify Visual Studio solution files.
alias ds='dotnet sln'
#Add a package or reference to a .NET project.
alias da='dotnet add'
#Create a NuGet package.
alias dp='dotnet pack'
#Provides additional NuGet commands.
alias dng='dotnet nuget'
#Build a .NET project
alias db='dotnet build'

# Aliases added by Chris Lebron (https://github.com/clebron949)
#List dotnet sdk versions installed
alias dls='dotnet --list-sdks'
#List dotnet runtimes installed
alias dlr='dotnet --list-runtimes'
