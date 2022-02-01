# bash completion support for Git.

if ! _omb_util_function_exists __gitdir; then
    is_completion_loaded=0
    for path in $(type -aP git);
    do
        path="${path%/git}"
        prefix="${path%/bin}"
        # echo "[debug] Checking $prefix"
        for file in share/bash-completion/completions/git share/git-core/contrib/completion/git-completion.bash;
        do
            _file="$prefix/$file"
            if [[ -f $_file && -r $_file ]]; then
                echo "[debug] Loading $_file"
                is_completion_loaded=1
                source "$_file"
                break 2
            fi
        done
    done
    if [[ $is_completion_loaded == 0 ]]; then
        # echo "[debug] No completion found: fallbacking"
        source "$OSH/tools/git-completion.bash"
    fi
# else
#    echo "[debug] __gitdir is a defined function: doing nothing"
fi
