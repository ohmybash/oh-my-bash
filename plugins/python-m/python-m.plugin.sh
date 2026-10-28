_omb_python_m_complete() {
    # Completion for `python -m` module names and package directories.
    local cur prev dir base entry matches dir_matches path is_dir
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ "$prev" == "-m" ]]; then
        path="${cur//.//}"
        dir="${path%/*}"
        base="${path##*/}"
        [[ "$path" != */* ]] && dir="."

        matches=()
        dir_matches=()
        while IFS= read -r -d '' entry; do
            entry="${entry##*/}"
            is_dir=0
            [[ -d "${dir}/${entry}" && "$dir" != "." ]] && is_dir=1
            [[ -d "${entry}" && "$dir" == "." ]] && is_dir=1
            entry="${entry%.py}"

            if [[ "$dir" != "." ]]; then
                entry="${dir//\//.}.${entry}"
            fi

            matches+=("$entry")
            [[ "$is_dir" == 1 ]] && dir_matches+=("$entry")
        done < <(find "$dir" -mindepth 1 -maxdepth 1 \( -name "${base}*.py" -o -name "${base}*" -type d \) ! -name "__pycache__" -print0 2>/dev/null)
        # Do not display __pycache__ directory as submodule

        COMPREPLY=( $(compgen -W "${matches[*]}" -- "$cur") )

        # if the single match is a package/directory, don't append a space so user can add a .
        if [[ "${#COMPREPLY[@]}" == 1 ]]; then
            for d in "${dir_matches[@]}"; do
                [[ "$d" == "${COMPREPLY[0]}" ]] && compopt -o nospace
            done
        fi
    else
        COMPREPLY=( $(compgen -f -- "$cur") )
    fi
}
complete -F _omb_python_m_complete python3
complete -F _omb_python_m_complete python
