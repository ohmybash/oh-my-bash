# bash completion support for Git.
_omb_completion_git_initialize() {
    if ! _omb_util_function_exists __gitdir; then
        local is_completion_loaded=0 path
        for path in $(type -aP git);
        do
            path="${path%/git}"
            local prefix="${path%/bin}" file
            for file in share/bash-completion/completions/git share/git-core/contrib/completion/git-completion.bash;
            do
                local _file="$prefix/$file"
                if [[ -f $_file && -r $_file ]]; then
                    is_completion_loaded=1
                    source "$_file"
                    break 2
                fi
            done
        done
        if [[ $is_completion_loaded == 0 ]]; then
            source "$OSH/tools/git-completion.bash"
        fi
    fi
}
_omb_completion_git_initialize
