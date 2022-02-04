# bash completion support for Git.
_omb_completion_git_initialize() {
    if ! _omb_util_function_exists __gitdir; then
        local path
        for path in $(type -aP git);
        do
            path="${path%/git}"
            local prefix="${path%/bin}" file
            for file in share/bash-completion/completions/git share/git-core/contrib/completion/git-completion.bash;
            do
                local _file="$prefix/$file"
                if [[ -f $_file && -r $_file ]]; then
                    source "$_file"
                    return
                fi
            done
        done
        source "$OSH/tools/git-completion.bash"
    fi
}
_omb_completion_git_initialize
