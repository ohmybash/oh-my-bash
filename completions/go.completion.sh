#! bash oh-my-bash.module
#
# bash completion for go tool
# https://github.com/thomasf/go-bash-completion/blob/73c7543f2a295d27ae9bc71baa1ef1a858447eae/go-bash-completion.bash
#------------------------------------------------------------------------------
# install in /etc/bash_completion.d/ or your personal directory

complete -f -X '!*.8' 8l
complete -f -X '!*.6' 6l
complete -f -X '!*.5' 5l
complete -f -X '!*.go' 8g 6g 5g gofmt gccgo

function _go_clear_cache {
  unset -v _go_imports
}
function _go_importpath_cache {
  if [[ ! ${_go_imports-} ]]; then
    _go_imports=$(go list all 2>/dev/null)
    export _go_imports
  fi
}

function _go_importpath {
  compgen -W "$_go_imports" -- "$1"
}

function _go {
  # TODO: Only allow flags before other arguments. run already does
  # this.

  local cur=$(_get_cword)
  local prev=${COMP_WORDS[COMP_CWORD-1]}

  local cmd=${COMP_WORDS[1]}

  local cmds="build clean doc env fix fmt get
    install list run test tool version vet"
  local addhelp="gopath importpath remote
    testflag testfunc"
  local other="help"
  local env_vars="GOARCH GOBIN GOEXE GOHOSTARCH GOHOSTOS GOOS GOPATH GORACE
    GOROOT GOTOOLDIR GO15VENDOREXPERIMENT CC GOGCCFLAGS CXX CGO_ENABLED"

  if ((COMP_CWORD == 1)); then
    local opt
    for opt in $cmds; do
      if [[ $opt == "$cmd" ]]; then
        COMPREPLY=("$opt")
        return 0
      fi
    done
  fi

  case $cmd in
  'build')
    case $prev in
    '-o')
      _filedir
      ;;
    '-p')
      ;;
    *)
      if [[ $cur == -* ]]; then
        COMPREPLY=($(compgen -W "-a -n -o -p -v -x" -- "$cur"))
      else
        local found=0 i
        for ((i=0; i < ${#COMP_WORDS[@]}; i++)); do
          case $i in
          0|1|"$COMP_CWORD")
            continue
            ;;
          esac
          local opt=${COMP_WORDS[i]}
          if [[ $opt != -* ]]; then
            if [[ $opt == *.go && -f $opt ]]; then
              found=1
              break
            else
              found=2
              break
            fi
          fi
        done
        case $found in
        0)
          _filedir go
          _go_importpath_cache
          COMPREPLY+=($(_go_importpath "$cur"))
          ;;
        1)
          _filedir go
          ;;
        2)
          _go_importpath_cache
          COMPREPLY=($(_go_importpath "$cur"))
          ;;
        esac
      fi
      ;;
    esac
    ;;
  'clean')
    if [[ $cur == -* ]]; then
      COMPREPLY=($(compgen -W "-i -r -n -x" -- "$cur"))
    else
      _go_importpath_cache
      COMPREPLY=($(_go_importpath "$cur"))
    fi
    ;;
  'doc')
    _go_importpath_cache
    COMPREPLY=($(_go_importpath "$cur"))
    ;;
  'env')
    COMPREPLY=($(compgen -W "$env_vars" -- "$cur"))
    ;;
  'fix')
    _go_importpath_cache
    COMPREPLY=($(_go_importpath "$cur"))
    ;;
  'fmt')
    _go_importpath_cache
    COMPREPLY=($(_go_importpath "$cur"))
    ;;
  'get')
    case $prev in
    '-p')
    ;;
    *)
      if [[ $cur == -* ]]; then
        COMPREPLY=($(compgen -W "-a -d -fix -n -p -u -v -x" -- "$cur"))
      else
        _go_importpath_cache
        COMPREPLY=($(_go_importpath "$cur"))
      fi
      ;;
    esac
    ;;
  'install')
    case $prev in
    '-p')
    ;;
    *)
      if [[ $cur == -* ]]; then
        COMPREPLY=($(compgen -W "-a -n -p -v -x" -- "$cur"))
      else
        _go_importpath_cache
        COMPREPLY=($(_go_importpath "$cur"))
      fi
      ;;
    esac
    ;;
  'list')
    case $prev in
    '-f')
    ;;
    *)
      if [[ $cur == -* ]]; then
        COMPREPLY=($(compgen -W "-e -f -json" -- "$cur"))
      else
        _go_importpath_cache
        COMPREPLY=($(_go_importpath "$cur"))
      fi
      ;;
    esac
    ;;
  'run')
    if [[ $cur == -* && $prev != *.go ]]; then
      COMPREPLY=($(compgen -W "-a -n -x" -- "$cur"))
    else
      _filedir
    fi
    ;;
  'test') # TODO: Support for testflags.
    case $prev in
    '-file')
      _filedir go
      ;;
    '-p')
      ;;
    *)
      if [[ $cur == -* ]]; then
        COMPREPLY=($(compgen -W "-c -file -i -p -x" -- "$cur"))
      else
        _go_importpath_cache
        COMPREPLY=($(_go_importpath "$cur"))
      fi
      ;;
    esac
    ;;
  'tool')
    if ((COMP_CWORD == 2)); then
      COMPREPLY=($(compgen -W "$(go tool)" -- "$cur"))
    else
      case ${COMP_WORDS[2]} in
      [568]a) # TODO: Implement something.
      #_go_tool_568a
      ;;
      [568]c) # TODO: Implement something.
      #_go_tool_568c
      ;;
      [568]g) # TODO: Implement something.
      #_go_tool_568g
      ;;
      [568]l) # TODO: Implement something.
      #_go_tool_568l
      ;;
      'api') # TODO: Implement something.
      #_go_tool_api
      ;;
      'cgo') # TODO: Implement something.
      #_go_tool_cgo
      ;;
      'cov') # TODO: Implement something.
      #_go_tool_cov
      ;;
      'dist') # TODO: Implement something.
      #_go_tool_dist
      ;;
      'ebnflint') # TODO: Implement something.
      #_go_tool_ebnflint
      ;;
      'fix') # TODO: Implement something.
      #_go_tool_fix
      ;;
      'gotype') # TODO: Implement something.
      #_go_tool_gotype
      ;;
      'nm') # TODO: Implement something.
      #_go_tool_nm
      ;;
      'pack') # TODO: Implement something.
      #_go_tool_pack
      ;;
      'pprof') # TODO: Implement something.
      #_go_tool_pprof
      ;;
      'prof') # TODO: Implement something.
      #_go_tool_prof
      ;;
      'vet') # TODO: Implement something.
      #_go_tool_vet
      ;;
      'yacc') # TODO: Implement something.
      #_go_tool_yacc
      ;;
      esac
      if [[ $cur == -* ]]; then
        COMPREPLY=($(compgen -W "${COMPREPLY[*]} -h" -- "$cur"))
      fi
    fi
    ;;
  'version')
    ;;
  'vet')
    if [[ $cur == -* ]]; then
      :
    else
      _go_importpath_cache
      COMPREPLY=($(_go_importpath "$cur"))
    fi
    ;;
  'help')
    if ((COMP_CWORD == 2)); then
      COMPREPLY=($(compgen -W "$cmds $addhelp" -- "$cur"))
    fi
    ;;
  *)
    if ((COMP_CWORD == 1)); then
      COMPREPLY=($(compgen -W "$cmds $other" -- "$cur"))
    else
      _filedir
    fi
    ;;
  esac
}

complete $filenames -F _go go

# vim:ts=2 sw=2 et syn=sh
