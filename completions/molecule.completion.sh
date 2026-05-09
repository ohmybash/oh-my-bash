#! bash oh-my-bash.module

# This file was written with the assistance of Copilot (GPT-5.2)
# based on an zsh implementaion found here https://github.com/ohmyzsh/ohmyzsh/pull/13587

# Only enable completion if molecule exists
command -v molecule >/dev/null 2>&1 || return 0

# Cache dir (pick one)
: "${BASH_CACHE_DIR:=${XDG_CACHE_HOME:-$HOME/.cache}/bash}"
mkdir -p "$BASH_CACHE_DIR/completions"

_molecule_comp="$BASH_CACHE_DIR/completions/molecule.bash"

# (Re)generate if missing (you can add your own staleness logic)
if [[ ! -f "$_molecule_comp" ]]; then
  _MOLECULE_COMPLETE=bash_source molecule >"$_molecule_comp" 2>/dev/null
fi

# Load the completion
# shellcheck source=/dev/null
[[ -s "$_molecule_comp" ]] && source "$_molecule_comp"

# Only add alias completion if the aliases exist
if [[ $(_omb_util_alias "mol" 2>/dev/null) ]]; then

  function _omb_completion_molecule {
    local -A commands=(
      [mol]='molecule'
      [mhlp]='molecule --help'
      [mchk]='molecule check'
      [mcln]='molecule cleanup'
      [mcnv]='molecule converge'
      [mcrt]='molecule create'
      [mdep]='molecule dependency'
      [mdes]='molecule destroy'
      [mdrv]='molecule drivers'
      [midm]='molecule idempotence'
      [minit]='molecule init scenario'
      [mlst]='molecule list'
      [mlgn]='molecule login'
      [mtrx]='molecule matrix'
      [mprp]='molecule prepare'
      [mrst]='molecule reset'
      [msef]='molecule side-effect'
      [msyn]='molecule syntax'
      [mtest]='molecule test'
      [mvrf]='molecule verify'
    )
    # Save original words
    local -a _orig_comp_words=("${COMP_WORDS[@]}")
    local _orig_comp_cword=$COMP_CWORD

    # Get the expanded word the current command
    expansion="${commands[$1]}"

    # Split on IFS whitespace into words
    read -r -a _exp_words <<<"$expansion"

    # Inject expansion words in place of the alias
    COMP_WORDS=("${_exp_words[@]}" "${COMP_WORDS[@]:1}")

    # Only bump COMP_CWORD by 1 if the expansion is multi-word, otherwise leave it.
    if [[ ${#_exp_words[@]} -gt 1 ]]; then
      COMP_CWORD=$((COMP_CWORD + 1))
    fi

    # Call the original completion function
    _molecule_completion molecule

    # Restore original words
    COMP_WORDS=("${_orig_comp_words[@]}")
    COMP_CWORD=$_orig_comp_cword
  }

  complete -o nosort -F _omb_completion_molecule mol
  complete -o nosort -F _omb_completion_molecule mhlp
  complete -o nosort -F _omb_completion_molecule mchk
  complete -o nosort -F _omb_completion_molecule mcln
  complete -o nosort -F _omb_completion_molecule mcnv
  complete -o nosort -F _omb_completion_molecule mcrt
  complete -o nosort -F _omb_completion_molecule mdep
  complete -o nosort -F _omb_completion_molecule mdes
  complete -o nosort -F _omb_completion_molecule mdrv
  complete -o nosort -F _omb_completion_molecule midm
  complete -o nosort -F _omb_completion_molecule minit
  complete -o nosort -F _omb_completion_molecule mlst
  complete -o nosort -F _omb_completion_molecule mlgn
  complete -o nosort -F _omb_completion_molecule mtrx
  complete -o nosort -F _omb_completion_molecule mprp
  complete -o nosort -F _omb_completion_molecule mrst
  complete -o nosort -F _omb_completion_molecule msef
  complete -o nosort -F _omb_completion_molecule msyn
  complete -o nosort -F _omb_completion_molecule mtest
  complete -o nosort -F _omb_completion_molecule mvrf
fi
