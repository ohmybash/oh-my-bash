# bash completion for ngrok                                -*- shell-script -*-

__ngrok_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE:-} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__ngrok_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__ngrok_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__ngrok_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__ngrok_handle_go_custom_completion()
{
    __ngrok_debug "${FUNCNAME[0]}: cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}"

    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16

    local out requestComp lastParam lastChar comp directive args

    # Prepare the command to request completions for the program.
    # Calling ${words[0]} instead of directly ngrok allows handling aliases
    args=("${words[@]:1}")
    # Disable ActiveHelp which is not supported for bash completion v1
    requestComp="NGROK_ACTIVE_HELP=0 ${words[0]} __completeNoDesc ${args[*]}"

    lastParam=${words[$((${#words[@]}-1))]}
    lastChar=${lastParam:$((${#lastParam}-1)):1}
    __ngrok_debug "${FUNCNAME[0]}: lastParam ${lastParam}, lastChar ${lastChar}"

    if [ -z "${cur}" ] && [ "${lastChar}" != "=" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __ngrok_debug "${FUNCNAME[0]}: Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __ngrok_debug "${FUNCNAME[0]}: calling ${requestComp}"
    # Use eval to handle any environment variables and such
    out=$(eval "${requestComp}" 2>/dev/null)

    # Extract the directive integer at the very end of the output following a colon (:)
    directive=${out##*:}
    # Remove the directive
    out=${out%:*}
    if [ "${directive}" = "${out}" ]; then
        # There is not directive specified
        directive=0
    fi
    __ngrok_debug "${FUNCNAME[0]}: the completion directive is: ${directive}"
    __ngrok_debug "${FUNCNAME[0]}: the completions are: ${out}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        # Error code.  No completion.
        __ngrok_debug "${FUNCNAME[0]}: received error from custom completion go code"
        return
    else
        if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __ngrok_debug "${FUNCNAME[0]}: activating no space"
                compopt -o nospace
            fi
        fi
        if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __ngrok_debug "${FUNCNAME[0]}: activating no file completion"
                compopt +o default
            fi
        fi
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local fullFilter filter filteringCmd
        # Do not use quotes around the $out variable or else newline
        # characters will be kept.
        for filter in ${out}; do
            fullFilter+="$filter|"
        done

        filteringCmd="_filedir $fullFilter"
        __ngrok_debug "File filtering command: $filteringCmd"
        $filteringCmd
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        # Use printf to strip any trailing newline
        subdir=$(printf "%s" "${out}")
        if [ -n "$subdir" ]; then
            __ngrok_debug "Listing directories in $subdir"
            __ngrok_handle_subdirs_in_dir_flag "$subdir"
        else
            __ngrok_debug "Listing directories in ."
            _filedir -d
        fi
    else
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${out}" -- "$cur")
    fi
}

__ngrok_handle_reply()
{
    __ngrok_debug "${FUNCNAME[0]}"
    local comp
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            while IFS='' read -r comp; do
                COMPREPLY+=("$comp")
            done < <(compgen -W "${allflags[*]}" -- "$cur")
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __ngrok_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION:-}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi

            if [[ -z "${flag_parsing_disabled}" ]]; then
                # If flag parsing is enabled, we have completed the flags and can return.
                # If flag parsing is disabled, we may not know all (or any) of the flags, so we fallthrough
                # to possibly call handle_go_custom_completion.
                return 0;
            fi
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __ngrok_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions+=("${must_have_one_noun[@]}")
    elif [[ -n "${has_completion_function}" ]]; then
        # if a go completion function is provided, defer to that function
        __ngrok_handle_go_custom_completion
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    while IFS='' read -r comp; do
        COMPREPLY+=("$comp")
    done < <(compgen -W "${completions[*]}" -- "$cur")

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${noun_aliases[*]}" -- "$cur")
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        if declare -F __ngrok_custom_func >/dev/null; then
            # try command name qualified custom func
            __ngrok_custom_func
        else
            # otherwise fall back to unqualified for compatibility
            declare -F __custom_func >/dev/null && __custom_func
        fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__ngrok_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__ngrok_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
}

__ngrok_handle_flag()
{
    __ngrok_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue=""
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __ngrok_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __ngrok_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __ngrok_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __ngrok_contains_word "${words[c]}" "${two_word_flags[@]}"; then
        __ngrok_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__ngrok_handle_noun()
{
    __ngrok_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __ngrok_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __ngrok_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__ngrok_handle_command()
{
    __ngrok_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_ngrok_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __ngrok_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__ngrok_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __ngrok_handle_reply
        return
    fi
    __ngrok_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __ngrok_handle_flag
    elif __ngrok_contains_word "${words[c]}" "${commands[@]}"; then
        __ngrok_handle_command
    elif [[ $c -eq 0 ]]; then
        __ngrok_handle_command
    elif __ngrok_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __ngrok_handle_command
        else
            __ngrok_handle_noun
        fi
    else
        __ngrok_handle_noun
    fi
    __ngrok_handle_word
}

_ngrok_api_abuse-reports_create()
{
    last_command="ngrok_api_abuse-reports_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--urls=")
    two_word_flags+=("--urls")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_abuse-reports_get()
{
    last_command="ngrok_api_abuse-reports_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_abuse-reports()
{
    last_command="ngrok_api_abuse-reports"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("get")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_agent-ingresses_create()
{
    last_command="ngrok_api_agent-ingresses_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--certificate-management-policy.authority=")
    two_word_flags+=("--certificate-management-policy.authority")
    flags+=("--certificate-management-policy.private-key-type=")
    two_word_flags+=("--certificate-management-policy.private-key-type")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--domain=")
    two_word_flags+=("--domain")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_agent-ingresses_delete()
{
    last_command="ngrok_api_agent-ingresses_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_agent-ingresses_get()
{
    last_command="ngrok_api_agent-ingresses_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_agent-ingresses_list()
{
    last_command="ngrok_api_agent-ingresses_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_agent-ingresses_update()
{
    last_command="ngrok_api_agent-ingresses_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--certificate-management-policy.authority=")
    two_word_flags+=("--certificate-management-policy.authority")
    flags+=("--certificate-management-policy.private-key-type=")
    two_word_flags+=("--certificate-management-policy.private-key-type")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_agent-ingresses()
{
    last_command="ngrok_api_agent-ingresses"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_api-keys_create()
{
    last_command="ngrok_api_api-keys_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--owner-id=")
    two_word_flags+=("--owner-id")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_api-keys_delete()
{
    last_command="ngrok_api_api-keys_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_api-keys_get()
{
    last_command="ngrok_api_api-keys_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_api-keys_list()
{
    last_command="ngrok_api_api-keys_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_api-keys_update()
{
    last_command="ngrok_api_api-keys_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_api-keys()
{
    last_command="ngrok_api_api-keys"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_application-sessions_delete()
{
    last_command="ngrok_api_application-sessions_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_application-sessions_get()
{
    last_command="ngrok_api_application-sessions_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_application-sessions_list()
{
    last_command="ngrok_api_application-sessions_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_application-sessions()
{
    last_command="ngrok_api_application-sessions"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("list")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_application-users_delete()
{
    last_command="ngrok_api_application-users_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_application-users_get()
{
    last_command="ngrok_api_application-users_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_application-users_list()
{
    last_command="ngrok_api_application-users_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_application-users()
{
    last_command="ngrok_api_application-users"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("list")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_failover_create()
{
    last_command="ngrok_api_backends_failover_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--backends=")
    two_word_flags+=("--backends")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_failover_delete()
{
    last_command="ngrok_api_backends_failover_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_failover_get()
{
    last_command="ngrok_api_backends_failover_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_failover_list()
{
    last_command="ngrok_api_backends_failover_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_failover_update()
{
    last_command="ngrok_api_backends_failover_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--backends=")
    two_word_flags+=("--backends")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_failover()
{
    last_command="ngrok_api_backends_failover"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_http-response_create()
{
    last_command="ngrok_api_backends_http-response_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--body=")
    two_word_flags+=("--body")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--headers=")
    two_word_flags+=("--headers")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--status-code=")
    two_word_flags+=("--status-code")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_http-response_delete()
{
    last_command="ngrok_api_backends_http-response_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_http-response_get()
{
    last_command="ngrok_api_backends_http-response_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_http-response_list()
{
    last_command="ngrok_api_backends_http-response_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_http-response_update()
{
    last_command="ngrok_api_backends_http-response_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--body=")
    two_word_flags+=("--body")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--headers=")
    two_word_flags+=("--headers")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--status-code=")
    two_word_flags+=("--status-code")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_http-response()
{
    last_command="ngrok_api_backends_http-response"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_static-address_create()
{
    last_command="ngrok_api_backends_static-address_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--address=")
    two_word_flags+=("--address")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--tls.enabled")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_static-address_delete()
{
    last_command="ngrok_api_backends_static-address_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_static-address_get()
{
    last_command="ngrok_api_backends_static-address_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_static-address_list()
{
    last_command="ngrok_api_backends_static-address_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_static-address_update()
{
    last_command="ngrok_api_backends_static-address_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--address=")
    two_word_flags+=("--address")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--tls.enabled")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_static-address()
{
    last_command="ngrok_api_backends_static-address"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_tunnel-group_create()
{
    last_command="ngrok_api_backends_tunnel-group_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--labels=")
    two_word_flags+=("--labels")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_tunnel-group_delete()
{
    last_command="ngrok_api_backends_tunnel-group_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_tunnel-group_get()
{
    last_command="ngrok_api_backends_tunnel-group_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_tunnel-group_list()
{
    last_command="ngrok_api_backends_tunnel-group_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_tunnel-group_update()
{
    last_command="ngrok_api_backends_tunnel-group_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--labels=")
    two_word_flags+=("--labels")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_tunnel-group()
{
    last_command="ngrok_api_backends_tunnel-group"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_weighted_create()
{
    last_command="ngrok_api_backends_weighted_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--backends=")
    two_word_flags+=("--backends")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_weighted_delete()
{
    last_command="ngrok_api_backends_weighted_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_weighted_get()
{
    last_command="ngrok_api_backends_weighted_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_weighted_list()
{
    last_command="ngrok_api_backends_weighted_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_weighted_update()
{
    last_command="ngrok_api_backends_weighted_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--backends=")
    two_word_flags+=("--backends")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends_weighted()
{
    last_command="ngrok_api_backends_weighted"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_backends()
{
    last_command="ngrok_api_backends"

    command_aliases=()

    commands=()
    commands+=("failover")
    commands+=("http-response")
    commands+=("static-address")
    commands+=("tunnel-group")
    commands+=("weighted")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_bot-users_create()
{
    last_command="ngrok_api_bot-users_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--active")
    flags+=("--name=")
    two_word_flags+=("--name")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_bot-users_delete()
{
    last_command="ngrok_api_bot-users_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_bot-users_get()
{
    last_command="ngrok_api_bot-users_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_bot-users_list()
{
    last_command="ngrok_api_bot-users_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_bot-users_update()
{
    last_command="ngrok_api_bot-users_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--active")
    flags+=("--name=")
    two_word_flags+=("--name")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_bot-users()
{
    last_command="ngrok_api_bot-users"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_certificate-authorities_create()
{
    last_command="ngrok_api_certificate-authorities_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-pem=")
    two_word_flags+=("--ca-pem")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_certificate-authorities_delete()
{
    last_command="ngrok_api_certificate-authorities_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_certificate-authorities_get()
{
    last_command="ngrok_api_certificate-authorities_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_certificate-authorities_list()
{
    last_command="ngrok_api_certificate-authorities_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_certificate-authorities_update()
{
    last_command="ngrok_api_certificate-authorities_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_certificate-authorities()
{
    last_command="ngrok_api_certificate-authorities"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_credentials_create()
{
    last_command="ngrok_api_credentials_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--acl=")
    two_word_flags+=("--acl")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--owner-id=")
    two_word_flags+=("--owner-id")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_credentials_delete()
{
    last_command="ngrok_api_credentials_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_credentials_get()
{
    last_command="ngrok_api_credentials_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_credentials_list()
{
    last_command="ngrok_api_credentials_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_credentials_update()
{
    last_command="ngrok_api_credentials_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--acl=")
    two_word_flags+=("--acl")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_credentials()
{
    last_command="ngrok_api_credentials"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-mutual-tls_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-mutual-tls_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-mutual-tls_get()
{
    last_command="ngrok_api_edge-modules_https-edge-mutual-tls_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-mutual-tls_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-mutual-tls_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.certificate-authority-ids=")
    two_word_flags+=("--module.certificate-authority-ids")
    flags+=("--module.enabled")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-mutual-tls()
{
    last_command="ngrok_api_edge-modules_https-edge-mutual-tls"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-backend_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-backend_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-backend_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-backend_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-backend_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-backend_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.backend-id=")
    two_word_flags+=("--module.backend-id")
    flags+=("--module.enabled")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-backend()
{
    last_command="ngrok_api_edge-modules_https-edge-route-backend"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-circuit-breaker_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-circuit-breaker_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-circuit-breaker_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-circuit-breaker_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-circuit-breaker_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-circuit-breaker_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.enabled")
    flags+=("--module.error-threshold-percentage=")
    two_word_flags+=("--module.error-threshold-percentage")
    flags+=("--module.num-buckets=")
    two_word_flags+=("--module.num-buckets")
    flags+=("--module.rolling-window=")
    two_word_flags+=("--module.rolling-window")
    flags+=("--module.tripped-duration=")
    two_word_flags+=("--module.tripped-duration")
    flags+=("--module.volume-threshold=")
    two_word_flags+=("--module.volume-threshold")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-circuit-breaker()
{
    last_command="ngrok_api_edge-modules_https-edge-route-circuit-breaker"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-compression_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-compression_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-compression_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-compression_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-compression_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-compression_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.enabled")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-compression()
{
    last_command="ngrok_api_edge-modules_https-edge-route-compression"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-ip-restriction_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-ip-restriction_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-ip-restriction_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-ip-restriction_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-ip-restriction_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-ip-restriction_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.enabled")
    flags+=("--module.ip-policy-ids=")
    two_word_flags+=("--module.ip-policy-ids")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-ip-restriction()
{
    last_command="ngrok_api_edge-modules_https-edge-route-ip-restriction"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-oauth_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-oauth_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-oauth_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-oauth_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-oauth_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-oauth_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.auth-check-interval=")
    two_word_flags+=("--module.auth-check-interval")
    flags+=("--module.cookie-prefix=")
    two_word_flags+=("--module.cookie-prefix")
    flags+=("--module.enabled")
    flags+=("--module.inactivity-timeout=")
    two_word_flags+=("--module.inactivity-timeout")
    flags+=("--module.maximum-duration=")
    two_word_flags+=("--module.maximum-duration")
    flags+=("--module.options-passthrough")
    flags+=("--module.provider.amazon.client-id=")
    two_word_flags+=("--module.provider.amazon.client-id")
    flags+=("--module.provider.amazon.client-secret=")
    two_word_flags+=("--module.provider.amazon.client-secret")
    flags+=("--module.provider.amazon.email-addresses=")
    two_word_flags+=("--module.provider.amazon.email-addresses")
    flags+=("--module.provider.amazon.email-domains=")
    two_word_flags+=("--module.provider.amazon.email-domains")
    flags+=("--module.provider.amazon.scopes=")
    two_word_flags+=("--module.provider.amazon.scopes")
    flags+=("--module.provider.facebook.client-id=")
    two_word_flags+=("--module.provider.facebook.client-id")
    flags+=("--module.provider.facebook.client-secret=")
    two_word_flags+=("--module.provider.facebook.client-secret")
    flags+=("--module.provider.facebook.email-addresses=")
    two_word_flags+=("--module.provider.facebook.email-addresses")
    flags+=("--module.provider.facebook.email-domains=")
    two_word_flags+=("--module.provider.facebook.email-domains")
    flags+=("--module.provider.facebook.scopes=")
    two_word_flags+=("--module.provider.facebook.scopes")
    flags+=("--module.provider.github.client-id=")
    two_word_flags+=("--module.provider.github.client-id")
    flags+=("--module.provider.github.client-secret=")
    two_word_flags+=("--module.provider.github.client-secret")
    flags+=("--module.provider.github.email-addresses=")
    two_word_flags+=("--module.provider.github.email-addresses")
    flags+=("--module.provider.github.email-domains=")
    two_word_flags+=("--module.provider.github.email-domains")
    flags+=("--module.provider.github.organizations=")
    two_word_flags+=("--module.provider.github.organizations")
    flags+=("--module.provider.github.scopes=")
    two_word_flags+=("--module.provider.github.scopes")
    flags+=("--module.provider.github.teams=")
    two_word_flags+=("--module.provider.github.teams")
    flags+=("--module.provider.gitlab.client-id=")
    two_word_flags+=("--module.provider.gitlab.client-id")
    flags+=("--module.provider.gitlab.client-secret=")
    two_word_flags+=("--module.provider.gitlab.client-secret")
    flags+=("--module.provider.gitlab.email-addresses=")
    two_word_flags+=("--module.provider.gitlab.email-addresses")
    flags+=("--module.provider.gitlab.email-domains=")
    two_word_flags+=("--module.provider.gitlab.email-domains")
    flags+=("--module.provider.gitlab.scopes=")
    two_word_flags+=("--module.provider.gitlab.scopes")
    flags+=("--module.provider.google.client-id=")
    two_word_flags+=("--module.provider.google.client-id")
    flags+=("--module.provider.google.client-secret=")
    two_word_flags+=("--module.provider.google.client-secret")
    flags+=("--module.provider.google.email-addresses=")
    two_word_flags+=("--module.provider.google.email-addresses")
    flags+=("--module.provider.google.email-domains=")
    two_word_flags+=("--module.provider.google.email-domains")
    flags+=("--module.provider.google.scopes=")
    two_word_flags+=("--module.provider.google.scopes")
    flags+=("--module.provider.linkedin.client-id=")
    two_word_flags+=("--module.provider.linkedin.client-id")
    flags+=("--module.provider.linkedin.client-secret=")
    two_word_flags+=("--module.provider.linkedin.client-secret")
    flags+=("--module.provider.linkedin.email-addresses=")
    two_word_flags+=("--module.provider.linkedin.email-addresses")
    flags+=("--module.provider.linkedin.email-domains=")
    two_word_flags+=("--module.provider.linkedin.email-domains")
    flags+=("--module.provider.linkedin.scopes=")
    two_word_flags+=("--module.provider.linkedin.scopes")
    flags+=("--module.provider.microsoft.client-id=")
    two_word_flags+=("--module.provider.microsoft.client-id")
    flags+=("--module.provider.microsoft.client-secret=")
    two_word_flags+=("--module.provider.microsoft.client-secret")
    flags+=("--module.provider.microsoft.email-addresses=")
    two_word_flags+=("--module.provider.microsoft.email-addresses")
    flags+=("--module.provider.microsoft.email-domains=")
    two_word_flags+=("--module.provider.microsoft.email-domains")
    flags+=("--module.provider.microsoft.scopes=")
    two_word_flags+=("--module.provider.microsoft.scopes")
    flags+=("--module.provider.twitch.client-id=")
    two_word_flags+=("--module.provider.twitch.client-id")
    flags+=("--module.provider.twitch.client-secret=")
    two_word_flags+=("--module.provider.twitch.client-secret")
    flags+=("--module.provider.twitch.email-addresses=")
    two_word_flags+=("--module.provider.twitch.email-addresses")
    flags+=("--module.provider.twitch.email-domains=")
    two_word_flags+=("--module.provider.twitch.email-domains")
    flags+=("--module.provider.twitch.scopes=")
    two_word_flags+=("--module.provider.twitch.scopes")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-oauth()
{
    last_command="ngrok_api_edge-modules_https-edge-route-oauth"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-oidc_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-oidc_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-oidc_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-oidc_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-oidc_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-oidc_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.client-id=")
    two_word_flags+=("--module.client-id")
    flags+=("--module.client-secret=")
    two_word_flags+=("--module.client-secret")
    flags+=("--module.cookie-prefix=")
    two_word_flags+=("--module.cookie-prefix")
    flags+=("--module.enabled")
    flags+=("--module.inactivity-timeout=")
    two_word_flags+=("--module.inactivity-timeout")
    flags+=("--module.issuer=")
    two_word_flags+=("--module.issuer")
    flags+=("--module.maximum-duration=")
    two_word_flags+=("--module.maximum-duration")
    flags+=("--module.options-passthrough")
    flags+=("--module.scopes=")
    two_word_flags+=("--module.scopes")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-oidc()
{
    last_command="ngrok_api_edge-modules_https-edge-route-oidc"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-request-headers_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-request-headers_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-request-headers_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-request-headers_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-request-headers_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-request-headers_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.add=")
    two_word_flags+=("--module.add")
    flags+=("--module.enabled")
    flags+=("--module.remove=")
    two_word_flags+=("--module.remove")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-request-headers()
{
    last_command="ngrok_api_edge-modules_https-edge-route-request-headers"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-response-headers_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-response-headers_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-response-headers_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-response-headers_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-response-headers_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-response-headers_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.add=")
    two_word_flags+=("--module.add")
    flags+=("--module.enabled")
    flags+=("--module.remove=")
    two_word_flags+=("--module.remove")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-response-headers()
{
    last_command="ngrok_api_edge-modules_https-edge-route-response-headers"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-saml_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-saml_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-saml_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-saml_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-saml_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-saml_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.allow-idp-initiated")
    flags+=("--module.authorized-groups=")
    two_word_flags+=("--module.authorized-groups")
    flags+=("--module.cookie-prefix=")
    two_word_flags+=("--module.cookie-prefix")
    flags+=("--module.enabled")
    flags+=("--module.force-authn")
    flags+=("--module.idp-metadata=")
    two_word_flags+=("--module.idp-metadata")
    flags+=("--module.inactivity-timeout=")
    two_word_flags+=("--module.inactivity-timeout")
    flags+=("--module.maximum-duration=")
    two_word_flags+=("--module.maximum-duration")
    flags+=("--module.nameid-format=")
    two_word_flags+=("--module.nameid-format")
    flags+=("--module.options-passthrough")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-saml()
{
    last_command="ngrok_api_edge-modules_https-edge-route-saml"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-traffic-policy_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-traffic-policy_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-traffic-policy_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-traffic-policy_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-traffic-policy_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-traffic-policy_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.enabled")
    flags+=("--module.value=")
    two_word_flags+=("--module.value")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-traffic-policy()
{
    last_command="ngrok_api_edge-modules_https-edge-route-traffic-policy"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-user-agent-filter_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-user-agent-filter_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-user-agent-filter_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-user-agent-filter_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-user-agent-filter_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-user-agent-filter_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.allow=")
    two_word_flags+=("--module.allow")
    flags+=("--module.deny=")
    two_word_flags+=("--module.deny")
    flags+=("--module.enabled")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-user-agent-filter()
{
    last_command="ngrok_api_edge-modules_https-edge-route-user-agent-filter"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-webhook-verification_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-webhook-verification_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-webhook-verification_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-webhook-verification_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-webhook-verification_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-webhook-verification_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.enabled")
    flags+=("--module.provider=")
    two_word_flags+=("--module.provider")
    flags+=("--module.secret=")
    two_word_flags+=("--module.secret")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-webhook-verification()
{
    last_command="ngrok_api_edge-modules_https-edge-route-webhook-verification"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-websocket-tcp-converter_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-route-websocket-tcp-converter_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-websocket-tcp-converter_get()
{
    last_command="ngrok_api_edge-modules_https-edge-route-websocket-tcp-converter_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-websocket-tcp-converter_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-route-websocket-tcp-converter_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.enabled")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-route-websocket-tcp-converter()
{
    last_command="ngrok_api_edge-modules_https-edge-route-websocket-tcp-converter"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-tls-termination_delete()
{
    last_command="ngrok_api_edge-modules_https-edge-tls-termination_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-tls-termination_get()
{
    last_command="ngrok_api_edge-modules_https-edge-tls-termination_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-tls-termination_replace()
{
    last_command="ngrok_api_edge-modules_https-edge-tls-termination_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.enabled")
    flags+=("--module.min-version=")
    two_word_flags+=("--module.min-version")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_https-edge-tls-termination()
{
    last_command="ngrok_api_edge-modules_https-edge-tls-termination"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tcp-edge-backend_delete()
{
    last_command="ngrok_api_edge-modules_tcp-edge-backend_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tcp-edge-backend_get()
{
    last_command="ngrok_api_edge-modules_tcp-edge-backend_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tcp-edge-backend_replace()
{
    last_command="ngrok_api_edge-modules_tcp-edge-backend_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.backend-id=")
    two_word_flags+=("--module.backend-id")
    flags+=("--module.enabled")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tcp-edge-backend()
{
    last_command="ngrok_api_edge-modules_tcp-edge-backend"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tcp-edge-ip-restriction_delete()
{
    last_command="ngrok_api_edge-modules_tcp-edge-ip-restriction_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tcp-edge-ip-restriction_get()
{
    last_command="ngrok_api_edge-modules_tcp-edge-ip-restriction_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tcp-edge-ip-restriction_replace()
{
    last_command="ngrok_api_edge-modules_tcp-edge-ip-restriction_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.enabled")
    flags+=("--module.ip-policy-ids=")
    two_word_flags+=("--module.ip-policy-ids")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tcp-edge-ip-restriction()
{
    last_command="ngrok_api_edge-modules_tcp-edge-ip-restriction"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tcp-edge-traffic-policy_delete()
{
    last_command="ngrok_api_edge-modules_tcp-edge-traffic-policy_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tcp-edge-traffic-policy_get()
{
    last_command="ngrok_api_edge-modules_tcp-edge-traffic-policy_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tcp-edge-traffic-policy_replace()
{
    last_command="ngrok_api_edge-modules_tcp-edge-traffic-policy_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.enabled")
    flags+=("--module.value=")
    two_word_flags+=("--module.value")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tcp-edge-traffic-policy()
{
    last_command="ngrok_api_edge-modules_tcp-edge-traffic-policy"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-backend_delete()
{
    last_command="ngrok_api_edge-modules_tls-edge-backend_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-backend_get()
{
    last_command="ngrok_api_edge-modules_tls-edge-backend_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-backend_replace()
{
    last_command="ngrok_api_edge-modules_tls-edge-backend_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.backend-id=")
    two_word_flags+=("--module.backend-id")
    flags+=("--module.enabled")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-backend()
{
    last_command="ngrok_api_edge-modules_tls-edge-backend"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-ip-restriction_delete()
{
    last_command="ngrok_api_edge-modules_tls-edge-ip-restriction_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-ip-restriction_get()
{
    last_command="ngrok_api_edge-modules_tls-edge-ip-restriction_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-ip-restriction_replace()
{
    last_command="ngrok_api_edge-modules_tls-edge-ip-restriction_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.enabled")
    flags+=("--module.ip-policy-ids=")
    two_word_flags+=("--module.ip-policy-ids")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-ip-restriction()
{
    last_command="ngrok_api_edge-modules_tls-edge-ip-restriction"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-mutual-tls_delete()
{
    last_command="ngrok_api_edge-modules_tls-edge-mutual-tls_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-mutual-tls_get()
{
    last_command="ngrok_api_edge-modules_tls-edge-mutual-tls_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-mutual-tls_replace()
{
    last_command="ngrok_api_edge-modules_tls-edge-mutual-tls_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.certificate-authority-ids=")
    two_word_flags+=("--module.certificate-authority-ids")
    flags+=("--module.enabled")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-mutual-tls()
{
    last_command="ngrok_api_edge-modules_tls-edge-mutual-tls"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-tls-termination_delete()
{
    last_command="ngrok_api_edge-modules_tls-edge-tls-termination_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-tls-termination_get()
{
    last_command="ngrok_api_edge-modules_tls-edge-tls-termination_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-tls-termination_replace()
{
    last_command="ngrok_api_edge-modules_tls-edge-tls-termination_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.enabled")
    flags+=("--module.min-version=")
    two_word_flags+=("--module.min-version")
    flags+=("--module.terminate-at=")
    two_word_flags+=("--module.terminate-at")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-tls-termination()
{
    last_command="ngrok_api_edge-modules_tls-edge-tls-termination"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-traffic-policy_delete()
{
    last_command="ngrok_api_edge-modules_tls-edge-traffic-policy_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-traffic-policy_get()
{
    last_command="ngrok_api_edge-modules_tls-edge-traffic-policy_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-traffic-policy_replace()
{
    last_command="ngrok_api_edge-modules_tls-edge-traffic-policy_replace"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--module.enabled")
    flags+=("--module.value=")
    two_word_flags+=("--module.value")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules_tls-edge-traffic-policy()
{
    last_command="ngrok_api_edge-modules_tls-edge-traffic-policy"

    command_aliases=()

    commands=()
    commands+=("delete")
    commands+=("get")
    commands+=("replace")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edge-modules()
{
    last_command="ngrok_api_edge-modules"

    command_aliases=()

    commands=()
    commands+=("https-edge-mutual-tls")
    commands+=("https-edge-route-backend")
    commands+=("https-edge-route-circuit-breaker")
    commands+=("https-edge-route-compression")
    commands+=("https-edge-route-ip-restriction")
    commands+=("https-edge-route-oauth")
    commands+=("https-edge-route-oidc")
    commands+=("https-edge-route-request-headers")
    commands+=("https-edge-route-response-headers")
    commands+=("https-edge-route-saml")
    commands+=("https-edge-route-traffic-policy")
    commands+=("https-edge-route-user-agent-filter")
    commands+=("https-edge-route-webhook-verification")
    commands+=("https-edge-route-websocket-tcp-converter")
    commands+=("https-edge-tls-termination")
    commands+=("tcp-edge-backend")
    commands+=("tcp-edge-ip-restriction")
    commands+=("tcp-edge-traffic-policy")
    commands+=("tls-edge-backend")
    commands+=("tls-edge-ip-restriction")
    commands+=("tls-edge-mutual-tls")
    commands+=("tls-edge-tls-termination")
    commands+=("tls-edge-traffic-policy")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_https_create()
{
    last_command="ngrok_api_edges_https_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--hostports=")
    two_word_flags+=("--hostports")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--mutual-tls.certificate-authority-ids=")
    two_word_flags+=("--mutual-tls.certificate-authority-ids")
    flags+=("--mutual-tls.enabled")
    flags+=("--tls-termination.enabled")
    flags+=("--tls-termination.min-version=")
    two_word_flags+=("--tls-termination.min-version")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_https_delete()
{
    last_command="ngrok_api_edges_https_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_https_get()
{
    last_command="ngrok_api_edges_https_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_https_list()
{
    last_command="ngrok_api_edges_https_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_https_update()
{
    last_command="ngrok_api_edges_https_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--hostports=")
    two_word_flags+=("--hostports")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--mutual-tls.certificate-authority-ids=")
    two_word_flags+=("--mutual-tls.certificate-authority-ids")
    flags+=("--mutual-tls.enabled")
    flags+=("--tls-termination.enabled")
    flags+=("--tls-termination.min-version=")
    two_word_flags+=("--tls-termination.min-version")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_https()
{
    last_command="ngrok_api_edges_https"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_https-routes_create()
{
    last_command="ngrok_api_edges_https-routes_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--backend.backend-id=")
    two_word_flags+=("--backend.backend-id")
    flags+=("--backend.enabled")
    flags+=("--circuit-breaker.enabled")
    flags+=("--circuit-breaker.error-threshold-percentage=")
    two_word_flags+=("--circuit-breaker.error-threshold-percentage")
    flags+=("--circuit-breaker.num-buckets=")
    two_word_flags+=("--circuit-breaker.num-buckets")
    flags+=("--circuit-breaker.rolling-window=")
    two_word_flags+=("--circuit-breaker.rolling-window")
    flags+=("--circuit-breaker.tripped-duration=")
    two_word_flags+=("--circuit-breaker.tripped-duration")
    flags+=("--circuit-breaker.volume-threshold=")
    two_word_flags+=("--circuit-breaker.volume-threshold")
    flags+=("--compression.enabled")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--ip-restriction.enabled")
    flags+=("--ip-restriction.ip-policy-ids=")
    two_word_flags+=("--ip-restriction.ip-policy-ids")
    flags+=("--match=")
    two_word_flags+=("--match")
    flags+=("--match-type=")
    two_word_flags+=("--match-type")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--oauth.auth-check-interval=")
    two_word_flags+=("--oauth.auth-check-interval")
    flags+=("--oauth.cookie-prefix=")
    two_word_flags+=("--oauth.cookie-prefix")
    flags+=("--oauth.enabled")
    flags+=("--oauth.inactivity-timeout=")
    two_word_flags+=("--oauth.inactivity-timeout")
    flags+=("--oauth.maximum-duration=")
    two_word_flags+=("--oauth.maximum-duration")
    flags+=("--oauth.options-passthrough")
    flags+=("--oauth.provider.amazon.client-id=")
    two_word_flags+=("--oauth.provider.amazon.client-id")
    flags+=("--oauth.provider.amazon.client-secret=")
    two_word_flags+=("--oauth.provider.amazon.client-secret")
    flags+=("--oauth.provider.amazon.email-addresses=")
    two_word_flags+=("--oauth.provider.amazon.email-addresses")
    flags+=("--oauth.provider.amazon.email-domains=")
    two_word_flags+=("--oauth.provider.amazon.email-domains")
    flags+=("--oauth.provider.amazon.scopes=")
    two_word_flags+=("--oauth.provider.amazon.scopes")
    flags+=("--oauth.provider.facebook.client-id=")
    two_word_flags+=("--oauth.provider.facebook.client-id")
    flags+=("--oauth.provider.facebook.client-secret=")
    two_word_flags+=("--oauth.provider.facebook.client-secret")
    flags+=("--oauth.provider.facebook.email-addresses=")
    two_word_flags+=("--oauth.provider.facebook.email-addresses")
    flags+=("--oauth.provider.facebook.email-domains=")
    two_word_flags+=("--oauth.provider.facebook.email-domains")
    flags+=("--oauth.provider.facebook.scopes=")
    two_word_flags+=("--oauth.provider.facebook.scopes")
    flags+=("--oauth.provider.github.client-id=")
    two_word_flags+=("--oauth.provider.github.client-id")
    flags+=("--oauth.provider.github.client-secret=")
    two_word_flags+=("--oauth.provider.github.client-secret")
    flags+=("--oauth.provider.github.email-addresses=")
    two_word_flags+=("--oauth.provider.github.email-addresses")
    flags+=("--oauth.provider.github.email-domains=")
    two_word_flags+=("--oauth.provider.github.email-domains")
    flags+=("--oauth.provider.github.organizations=")
    two_word_flags+=("--oauth.provider.github.organizations")
    flags+=("--oauth.provider.github.scopes=")
    two_word_flags+=("--oauth.provider.github.scopes")
    flags+=("--oauth.provider.github.teams=")
    two_word_flags+=("--oauth.provider.github.teams")
    flags+=("--oauth.provider.gitlab.client-id=")
    two_word_flags+=("--oauth.provider.gitlab.client-id")
    flags+=("--oauth.provider.gitlab.client-secret=")
    two_word_flags+=("--oauth.provider.gitlab.client-secret")
    flags+=("--oauth.provider.gitlab.email-addresses=")
    two_word_flags+=("--oauth.provider.gitlab.email-addresses")
    flags+=("--oauth.provider.gitlab.email-domains=")
    two_word_flags+=("--oauth.provider.gitlab.email-domains")
    flags+=("--oauth.provider.gitlab.scopes=")
    two_word_flags+=("--oauth.provider.gitlab.scopes")
    flags+=("--oauth.provider.google.client-id=")
    two_word_flags+=("--oauth.provider.google.client-id")
    flags+=("--oauth.provider.google.client-secret=")
    two_word_flags+=("--oauth.provider.google.client-secret")
    flags+=("--oauth.provider.google.email-addresses=")
    two_word_flags+=("--oauth.provider.google.email-addresses")
    flags+=("--oauth.provider.google.email-domains=")
    two_word_flags+=("--oauth.provider.google.email-domains")
    flags+=("--oauth.provider.google.scopes=")
    two_word_flags+=("--oauth.provider.google.scopes")
    flags+=("--oauth.provider.linkedin.client-id=")
    two_word_flags+=("--oauth.provider.linkedin.client-id")
    flags+=("--oauth.provider.linkedin.client-secret=")
    two_word_flags+=("--oauth.provider.linkedin.client-secret")
    flags+=("--oauth.provider.linkedin.email-addresses=")
    two_word_flags+=("--oauth.provider.linkedin.email-addresses")
    flags+=("--oauth.provider.linkedin.email-domains=")
    two_word_flags+=("--oauth.provider.linkedin.email-domains")
    flags+=("--oauth.provider.linkedin.scopes=")
    two_word_flags+=("--oauth.provider.linkedin.scopes")
    flags+=("--oauth.provider.microsoft.client-id=")
    two_word_flags+=("--oauth.provider.microsoft.client-id")
    flags+=("--oauth.provider.microsoft.client-secret=")
    two_word_flags+=("--oauth.provider.microsoft.client-secret")
    flags+=("--oauth.provider.microsoft.email-addresses=")
    two_word_flags+=("--oauth.provider.microsoft.email-addresses")
    flags+=("--oauth.provider.microsoft.email-domains=")
    two_word_flags+=("--oauth.provider.microsoft.email-domains")
    flags+=("--oauth.provider.microsoft.scopes=")
    two_word_flags+=("--oauth.provider.microsoft.scopes")
    flags+=("--oauth.provider.twitch.client-id=")
    two_word_flags+=("--oauth.provider.twitch.client-id")
    flags+=("--oauth.provider.twitch.client-secret=")
    two_word_flags+=("--oauth.provider.twitch.client-secret")
    flags+=("--oauth.provider.twitch.email-addresses=")
    two_word_flags+=("--oauth.provider.twitch.email-addresses")
    flags+=("--oauth.provider.twitch.email-domains=")
    two_word_flags+=("--oauth.provider.twitch.email-domains")
    flags+=("--oauth.provider.twitch.scopes=")
    two_word_flags+=("--oauth.provider.twitch.scopes")
    flags+=("--oidc.client-id=")
    two_word_flags+=("--oidc.client-id")
    flags+=("--oidc.client-secret=")
    two_word_flags+=("--oidc.client-secret")
    flags+=("--oidc.cookie-prefix=")
    two_word_flags+=("--oidc.cookie-prefix")
    flags+=("--oidc.enabled")
    flags+=("--oidc.inactivity-timeout=")
    two_word_flags+=("--oidc.inactivity-timeout")
    flags+=("--oidc.issuer=")
    two_word_flags+=("--oidc.issuer")
    flags+=("--oidc.maximum-duration=")
    two_word_flags+=("--oidc.maximum-duration")
    flags+=("--oidc.options-passthrough")
    flags+=("--oidc.scopes=")
    two_word_flags+=("--oidc.scopes")
    flags+=("--request-headers.add=")
    two_word_flags+=("--request-headers.add")
    flags+=("--request-headers.enabled")
    flags+=("--request-headers.remove=")
    two_word_flags+=("--request-headers.remove")
    flags+=("--response-headers.add=")
    two_word_flags+=("--response-headers.add")
    flags+=("--response-headers.enabled")
    flags+=("--response-headers.remove=")
    two_word_flags+=("--response-headers.remove")
    flags+=("--saml.allow-idp-initiated")
    flags+=("--saml.authorized-groups=")
    two_word_flags+=("--saml.authorized-groups")
    flags+=("--saml.cookie-prefix=")
    two_word_flags+=("--saml.cookie-prefix")
    flags+=("--saml.enabled")
    flags+=("--saml.force-authn")
    flags+=("--saml.idp-metadata=")
    two_word_flags+=("--saml.idp-metadata")
    flags+=("--saml.inactivity-timeout=")
    two_word_flags+=("--saml.inactivity-timeout")
    flags+=("--saml.maximum-duration=")
    two_word_flags+=("--saml.maximum-duration")
    flags+=("--saml.nameid-format=")
    two_word_flags+=("--saml.nameid-format")
    flags+=("--saml.options-passthrough")
    flags+=("--traffic-policy.enabled")
    flags+=("--traffic-policy.value=")
    two_word_flags+=("--traffic-policy.value")
    flags+=("--user-agent-filter.allow=")
    two_word_flags+=("--user-agent-filter.allow")
    flags+=("--user-agent-filter.deny=")
    two_word_flags+=("--user-agent-filter.deny")
    flags+=("--user-agent-filter.enabled")
    flags+=("--webhook-verification.enabled")
    flags+=("--webhook-verification.provider=")
    two_word_flags+=("--webhook-verification.provider")
    flags+=("--webhook-verification.secret=")
    two_word_flags+=("--webhook-verification.secret")
    flags+=("--websocket-tcp-converter.enabled")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_https-routes_delete()
{
    last_command="ngrok_api_edges_https-routes_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_https-routes_get()
{
    last_command="ngrok_api_edges_https-routes_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_https-routes_update()
{
    last_command="ngrok_api_edges_https-routes_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--backend.backend-id=")
    two_word_flags+=("--backend.backend-id")
    flags+=("--backend.enabled")
    flags+=("--circuit-breaker.enabled")
    flags+=("--circuit-breaker.error-threshold-percentage=")
    two_word_flags+=("--circuit-breaker.error-threshold-percentage")
    flags+=("--circuit-breaker.num-buckets=")
    two_word_flags+=("--circuit-breaker.num-buckets")
    flags+=("--circuit-breaker.rolling-window=")
    two_word_flags+=("--circuit-breaker.rolling-window")
    flags+=("--circuit-breaker.tripped-duration=")
    two_word_flags+=("--circuit-breaker.tripped-duration")
    flags+=("--circuit-breaker.volume-threshold=")
    two_word_flags+=("--circuit-breaker.volume-threshold")
    flags+=("--compression.enabled")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--ip-restriction.enabled")
    flags+=("--ip-restriction.ip-policy-ids=")
    two_word_flags+=("--ip-restriction.ip-policy-ids")
    flags+=("--match=")
    two_word_flags+=("--match")
    flags+=("--match-type=")
    two_word_flags+=("--match-type")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--oauth.auth-check-interval=")
    two_word_flags+=("--oauth.auth-check-interval")
    flags+=("--oauth.cookie-prefix=")
    two_word_flags+=("--oauth.cookie-prefix")
    flags+=("--oauth.enabled")
    flags+=("--oauth.inactivity-timeout=")
    two_word_flags+=("--oauth.inactivity-timeout")
    flags+=("--oauth.maximum-duration=")
    two_word_flags+=("--oauth.maximum-duration")
    flags+=("--oauth.options-passthrough")
    flags+=("--oauth.provider.amazon.client-id=")
    two_word_flags+=("--oauth.provider.amazon.client-id")
    flags+=("--oauth.provider.amazon.client-secret=")
    two_word_flags+=("--oauth.provider.amazon.client-secret")
    flags+=("--oauth.provider.amazon.email-addresses=")
    two_word_flags+=("--oauth.provider.amazon.email-addresses")
    flags+=("--oauth.provider.amazon.email-domains=")
    two_word_flags+=("--oauth.provider.amazon.email-domains")
    flags+=("--oauth.provider.amazon.scopes=")
    two_word_flags+=("--oauth.provider.amazon.scopes")
    flags+=("--oauth.provider.facebook.client-id=")
    two_word_flags+=("--oauth.provider.facebook.client-id")
    flags+=("--oauth.provider.facebook.client-secret=")
    two_word_flags+=("--oauth.provider.facebook.client-secret")
    flags+=("--oauth.provider.facebook.email-addresses=")
    two_word_flags+=("--oauth.provider.facebook.email-addresses")
    flags+=("--oauth.provider.facebook.email-domains=")
    two_word_flags+=("--oauth.provider.facebook.email-domains")
    flags+=("--oauth.provider.facebook.scopes=")
    two_word_flags+=("--oauth.provider.facebook.scopes")
    flags+=("--oauth.provider.github.client-id=")
    two_word_flags+=("--oauth.provider.github.client-id")
    flags+=("--oauth.provider.github.client-secret=")
    two_word_flags+=("--oauth.provider.github.client-secret")
    flags+=("--oauth.provider.github.email-addresses=")
    two_word_flags+=("--oauth.provider.github.email-addresses")
    flags+=("--oauth.provider.github.email-domains=")
    two_word_flags+=("--oauth.provider.github.email-domains")
    flags+=("--oauth.provider.github.organizations=")
    two_word_flags+=("--oauth.provider.github.organizations")
    flags+=("--oauth.provider.github.scopes=")
    two_word_flags+=("--oauth.provider.github.scopes")
    flags+=("--oauth.provider.github.teams=")
    two_word_flags+=("--oauth.provider.github.teams")
    flags+=("--oauth.provider.gitlab.client-id=")
    two_word_flags+=("--oauth.provider.gitlab.client-id")
    flags+=("--oauth.provider.gitlab.client-secret=")
    two_word_flags+=("--oauth.provider.gitlab.client-secret")
    flags+=("--oauth.provider.gitlab.email-addresses=")
    two_word_flags+=("--oauth.provider.gitlab.email-addresses")
    flags+=("--oauth.provider.gitlab.email-domains=")
    two_word_flags+=("--oauth.provider.gitlab.email-domains")
    flags+=("--oauth.provider.gitlab.scopes=")
    two_word_flags+=("--oauth.provider.gitlab.scopes")
    flags+=("--oauth.provider.google.client-id=")
    two_word_flags+=("--oauth.provider.google.client-id")
    flags+=("--oauth.provider.google.client-secret=")
    two_word_flags+=("--oauth.provider.google.client-secret")
    flags+=("--oauth.provider.google.email-addresses=")
    two_word_flags+=("--oauth.provider.google.email-addresses")
    flags+=("--oauth.provider.google.email-domains=")
    two_word_flags+=("--oauth.provider.google.email-domains")
    flags+=("--oauth.provider.google.scopes=")
    two_word_flags+=("--oauth.provider.google.scopes")
    flags+=("--oauth.provider.linkedin.client-id=")
    two_word_flags+=("--oauth.provider.linkedin.client-id")
    flags+=("--oauth.provider.linkedin.client-secret=")
    two_word_flags+=("--oauth.provider.linkedin.client-secret")
    flags+=("--oauth.provider.linkedin.email-addresses=")
    two_word_flags+=("--oauth.provider.linkedin.email-addresses")
    flags+=("--oauth.provider.linkedin.email-domains=")
    two_word_flags+=("--oauth.provider.linkedin.email-domains")
    flags+=("--oauth.provider.linkedin.scopes=")
    two_word_flags+=("--oauth.provider.linkedin.scopes")
    flags+=("--oauth.provider.microsoft.client-id=")
    two_word_flags+=("--oauth.provider.microsoft.client-id")
    flags+=("--oauth.provider.microsoft.client-secret=")
    two_word_flags+=("--oauth.provider.microsoft.client-secret")
    flags+=("--oauth.provider.microsoft.email-addresses=")
    two_word_flags+=("--oauth.provider.microsoft.email-addresses")
    flags+=("--oauth.provider.microsoft.email-domains=")
    two_word_flags+=("--oauth.provider.microsoft.email-domains")
    flags+=("--oauth.provider.microsoft.scopes=")
    two_word_flags+=("--oauth.provider.microsoft.scopes")
    flags+=("--oauth.provider.twitch.client-id=")
    two_word_flags+=("--oauth.provider.twitch.client-id")
    flags+=("--oauth.provider.twitch.client-secret=")
    two_word_flags+=("--oauth.provider.twitch.client-secret")
    flags+=("--oauth.provider.twitch.email-addresses=")
    two_word_flags+=("--oauth.provider.twitch.email-addresses")
    flags+=("--oauth.provider.twitch.email-domains=")
    two_word_flags+=("--oauth.provider.twitch.email-domains")
    flags+=("--oauth.provider.twitch.scopes=")
    two_word_flags+=("--oauth.provider.twitch.scopes")
    flags+=("--oidc.client-id=")
    two_word_flags+=("--oidc.client-id")
    flags+=("--oidc.client-secret=")
    two_word_flags+=("--oidc.client-secret")
    flags+=("--oidc.cookie-prefix=")
    two_word_flags+=("--oidc.cookie-prefix")
    flags+=("--oidc.enabled")
    flags+=("--oidc.inactivity-timeout=")
    two_word_flags+=("--oidc.inactivity-timeout")
    flags+=("--oidc.issuer=")
    two_word_flags+=("--oidc.issuer")
    flags+=("--oidc.maximum-duration=")
    two_word_flags+=("--oidc.maximum-duration")
    flags+=("--oidc.options-passthrough")
    flags+=("--oidc.scopes=")
    two_word_flags+=("--oidc.scopes")
    flags+=("--request-headers.add=")
    two_word_flags+=("--request-headers.add")
    flags+=("--request-headers.enabled")
    flags+=("--request-headers.remove=")
    two_word_flags+=("--request-headers.remove")
    flags+=("--response-headers.add=")
    two_word_flags+=("--response-headers.add")
    flags+=("--response-headers.enabled")
    flags+=("--response-headers.remove=")
    two_word_flags+=("--response-headers.remove")
    flags+=("--saml.allow-idp-initiated")
    flags+=("--saml.authorized-groups=")
    two_word_flags+=("--saml.authorized-groups")
    flags+=("--saml.cookie-prefix=")
    two_word_flags+=("--saml.cookie-prefix")
    flags+=("--saml.enabled")
    flags+=("--saml.force-authn")
    flags+=("--saml.idp-metadata=")
    two_word_flags+=("--saml.idp-metadata")
    flags+=("--saml.inactivity-timeout=")
    two_word_flags+=("--saml.inactivity-timeout")
    flags+=("--saml.maximum-duration=")
    two_word_flags+=("--saml.maximum-duration")
    flags+=("--saml.nameid-format=")
    two_word_flags+=("--saml.nameid-format")
    flags+=("--saml.options-passthrough")
    flags+=("--traffic-policy.enabled")
    flags+=("--traffic-policy.value=")
    two_word_flags+=("--traffic-policy.value")
    flags+=("--user-agent-filter.allow=")
    two_word_flags+=("--user-agent-filter.allow")
    flags+=("--user-agent-filter.deny=")
    two_word_flags+=("--user-agent-filter.deny")
    flags+=("--user-agent-filter.enabled")
    flags+=("--webhook-verification.enabled")
    flags+=("--webhook-verification.provider=")
    two_word_flags+=("--webhook-verification.provider")
    flags+=("--webhook-verification.secret=")
    two_word_flags+=("--webhook-verification.secret")
    flags+=("--websocket-tcp-converter.enabled")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_https-routes()
{
    last_command="ngrok_api_edges_https-routes"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_tcp_create()
{
    last_command="ngrok_api_edges_tcp_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--backend.backend-id=")
    two_word_flags+=("--backend.backend-id")
    flags+=("--backend.enabled")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--hostports=")
    two_word_flags+=("--hostports")
    flags+=("--ip-restriction.enabled")
    flags+=("--ip-restriction.ip-policy-ids=")
    two_word_flags+=("--ip-restriction.ip-policy-ids")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--traffic-policy.enabled")
    flags+=("--traffic-policy.value=")
    two_word_flags+=("--traffic-policy.value")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_tcp_delete()
{
    last_command="ngrok_api_edges_tcp_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_tcp_get()
{
    last_command="ngrok_api_edges_tcp_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_tcp_list()
{
    last_command="ngrok_api_edges_tcp_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_tcp_update()
{
    last_command="ngrok_api_edges_tcp_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--backend.backend-id=")
    two_word_flags+=("--backend.backend-id")
    flags+=("--backend.enabled")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--hostports=")
    two_word_flags+=("--hostports")
    flags+=("--ip-restriction.enabled")
    flags+=("--ip-restriction.ip-policy-ids=")
    two_word_flags+=("--ip-restriction.ip-policy-ids")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--traffic-policy.enabled")
    flags+=("--traffic-policy.value=")
    two_word_flags+=("--traffic-policy.value")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_tcp()
{
    last_command="ngrok_api_edges_tcp"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_tls_create()
{
    last_command="ngrok_api_edges_tls_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--backend.backend-id=")
    two_word_flags+=("--backend.backend-id")
    flags+=("--backend.enabled")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--hostports=")
    two_word_flags+=("--hostports")
    flags+=("--ip-restriction.enabled")
    flags+=("--ip-restriction.ip-policy-ids=")
    two_word_flags+=("--ip-restriction.ip-policy-ids")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--mutual-tls.certificate-authority-ids=")
    two_word_flags+=("--mutual-tls.certificate-authority-ids")
    flags+=("--mutual-tls.enabled")
    flags+=("--tls-termination.enabled")
    flags+=("--tls-termination.min-version=")
    two_word_flags+=("--tls-termination.min-version")
    flags+=("--tls-termination.terminate-at=")
    two_word_flags+=("--tls-termination.terminate-at")
    flags+=("--traffic-policy.enabled")
    flags+=("--traffic-policy.value=")
    two_word_flags+=("--traffic-policy.value")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_tls_delete()
{
    last_command="ngrok_api_edges_tls_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_tls_get()
{
    last_command="ngrok_api_edges_tls_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_tls_list()
{
    last_command="ngrok_api_edges_tls_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_tls_update()
{
    last_command="ngrok_api_edges_tls_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--backend.backend-id=")
    two_word_flags+=("--backend.backend-id")
    flags+=("--backend.enabled")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--hostports=")
    two_word_flags+=("--hostports")
    flags+=("--ip-restriction.enabled")
    flags+=("--ip-restriction.ip-policy-ids=")
    two_word_flags+=("--ip-restriction.ip-policy-ids")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--mutual-tls.certificate-authority-ids=")
    two_word_flags+=("--mutual-tls.certificate-authority-ids")
    flags+=("--mutual-tls.enabled")
    flags+=("--tls-termination.enabled")
    flags+=("--tls-termination.min-version=")
    two_word_flags+=("--tls-termination.min-version")
    flags+=("--tls-termination.terminate-at=")
    two_word_flags+=("--tls-termination.terminate-at")
    flags+=("--traffic-policy.enabled")
    flags+=("--traffic-policy.value=")
    two_word_flags+=("--traffic-policy.value")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges_tls()
{
    last_command="ngrok_api_edges_tls"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_edges()
{
    last_command="ngrok_api_edges"

    command_aliases=()

    commands=()
    commands+=("https")
    commands+=("https-routes")
    commands+=("tcp")
    commands+=("tls")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_endpoints_create()
{
    last_command="ngrok_api_endpoints_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--bindings=")
    two_word_flags+=("--bindings")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--traffic-policy=")
    two_word_flags+=("--traffic-policy")
    flags+=("--type=")
    two_word_flags+=("--type")
    flags+=("--url=")
    two_word_flags+=("--url")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_endpoints_delete()
{
    last_command="ngrok_api_endpoints_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_endpoints_get()
{
    last_command="ngrok_api_endpoints_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_endpoints_list()
{
    last_command="ngrok_api_endpoints_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_endpoints_update()
{
    last_command="ngrok_api_endpoints_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--bindings=")
    two_word_flags+=("--bindings")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--traffic-policy=")
    two_word_flags+=("--traffic-policy")
    flags+=("--url=")
    two_word_flags+=("--url")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_endpoints()
{
    last_command="ngrok_api_endpoints"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-destinations_create()
{
    last_command="ngrok_api_event-destinations_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--target.azure-logs-ingestion.client-id=")
    two_word_flags+=("--target.azure-logs-ingestion.client-id")
    flags+=("--target.azure-logs-ingestion.client-secret=")
    two_word_flags+=("--target.azure-logs-ingestion.client-secret")
    flags+=("--target.azure-logs-ingestion.data-collection-rule-id=")
    two_word_flags+=("--target.azure-logs-ingestion.data-collection-rule-id")
    flags+=("--target.azure-logs-ingestion.data-collection-stream-name=")
    two_word_flags+=("--target.azure-logs-ingestion.data-collection-stream-name")
    flags+=("--target.azure-logs-ingestion.logs-ingestion-uri=")
    two_word_flags+=("--target.azure-logs-ingestion.logs-ingestion-uri")
    flags+=("--target.azure-logs-ingestion.tenant-id=")
    two_word_flags+=("--target.azure-logs-ingestion.tenant-id")
    flags+=("--target.cloudwatch-logs.auth.creds.aws-access-key-id=")
    two_word_flags+=("--target.cloudwatch-logs.auth.creds.aws-access-key-id")
    flags+=("--target.cloudwatch-logs.auth.creds.aws-secret-access-key=")
    two_word_flags+=("--target.cloudwatch-logs.auth.creds.aws-secret-access-key")
    flags+=("--target.cloudwatch-logs.auth.role.role-arn=")
    two_word_flags+=("--target.cloudwatch-logs.auth.role.role-arn")
    flags+=("--target.cloudwatch-logs.log-group-arn=")
    two_word_flags+=("--target.cloudwatch-logs.log-group-arn")
    flags+=("--target.datadog.api-key=")
    two_word_flags+=("--target.datadog.api-key")
    flags+=("--target.datadog.ddsite=")
    two_word_flags+=("--target.datadog.ddsite")
    flags+=("--target.datadog.ddtags=")
    two_word_flags+=("--target.datadog.ddtags")
    flags+=("--target.datadog.service=")
    two_word_flags+=("--target.datadog.service")
    flags+=("--target.firehose.auth.creds.aws-access-key-id=")
    two_word_flags+=("--target.firehose.auth.creds.aws-access-key-id")
    flags+=("--target.firehose.auth.creds.aws-secret-access-key=")
    two_word_flags+=("--target.firehose.auth.creds.aws-secret-access-key")
    flags+=("--target.firehose.auth.role.role-arn=")
    two_word_flags+=("--target.firehose.auth.role.role-arn")
    flags+=("--target.firehose.delivery-stream-arn=")
    two_word_flags+=("--target.firehose.delivery-stream-arn")
    flags+=("--target.kinesis.auth.creds.aws-access-key-id=")
    two_word_flags+=("--target.kinesis.auth.creds.aws-access-key-id")
    flags+=("--target.kinesis.auth.creds.aws-secret-access-key=")
    two_word_flags+=("--target.kinesis.auth.creds.aws-secret-access-key")
    flags+=("--target.kinesis.auth.role.role-arn=")
    two_word_flags+=("--target.kinesis.auth.role.role-arn")
    flags+=("--target.kinesis.stream-arn=")
    two_word_flags+=("--target.kinesis.stream-arn")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-destinations_delete()
{
    last_command="ngrok_api_event-destinations_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-destinations_get()
{
    last_command="ngrok_api_event-destinations_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-destinations_list()
{
    last_command="ngrok_api_event-destinations_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-destinations_update()
{
    last_command="ngrok_api_event-destinations_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--target.azure-logs-ingestion.client-id=")
    two_word_flags+=("--target.azure-logs-ingestion.client-id")
    flags+=("--target.azure-logs-ingestion.client-secret=")
    two_word_flags+=("--target.azure-logs-ingestion.client-secret")
    flags+=("--target.azure-logs-ingestion.data-collection-rule-id=")
    two_word_flags+=("--target.azure-logs-ingestion.data-collection-rule-id")
    flags+=("--target.azure-logs-ingestion.data-collection-stream-name=")
    two_word_flags+=("--target.azure-logs-ingestion.data-collection-stream-name")
    flags+=("--target.azure-logs-ingestion.logs-ingestion-uri=")
    two_word_flags+=("--target.azure-logs-ingestion.logs-ingestion-uri")
    flags+=("--target.azure-logs-ingestion.tenant-id=")
    two_word_flags+=("--target.azure-logs-ingestion.tenant-id")
    flags+=("--target.cloudwatch-logs.auth.creds.aws-access-key-id=")
    two_word_flags+=("--target.cloudwatch-logs.auth.creds.aws-access-key-id")
    flags+=("--target.cloudwatch-logs.auth.creds.aws-secret-access-key=")
    two_word_flags+=("--target.cloudwatch-logs.auth.creds.aws-secret-access-key")
    flags+=("--target.cloudwatch-logs.auth.role.role-arn=")
    two_word_flags+=("--target.cloudwatch-logs.auth.role.role-arn")
    flags+=("--target.cloudwatch-logs.log-group-arn=")
    two_word_flags+=("--target.cloudwatch-logs.log-group-arn")
    flags+=("--target.datadog.api-key=")
    two_word_flags+=("--target.datadog.api-key")
    flags+=("--target.datadog.ddsite=")
    two_word_flags+=("--target.datadog.ddsite")
    flags+=("--target.datadog.ddtags=")
    two_word_flags+=("--target.datadog.ddtags")
    flags+=("--target.datadog.service=")
    two_word_flags+=("--target.datadog.service")
    flags+=("--target.firehose.auth.creds.aws-access-key-id=")
    two_word_flags+=("--target.firehose.auth.creds.aws-access-key-id")
    flags+=("--target.firehose.auth.creds.aws-secret-access-key=")
    two_word_flags+=("--target.firehose.auth.creds.aws-secret-access-key")
    flags+=("--target.firehose.auth.role.role-arn=")
    two_word_flags+=("--target.firehose.auth.role.role-arn")
    flags+=("--target.firehose.delivery-stream-arn=")
    two_word_flags+=("--target.firehose.delivery-stream-arn")
    flags+=("--target.kinesis.auth.creds.aws-access-key-id=")
    two_word_flags+=("--target.kinesis.auth.creds.aws-access-key-id")
    flags+=("--target.kinesis.auth.creds.aws-secret-access-key=")
    two_word_flags+=("--target.kinesis.auth.creds.aws-secret-access-key")
    flags+=("--target.kinesis.auth.role.role-arn=")
    two_word_flags+=("--target.kinesis.auth.role.role-arn")
    flags+=("--target.kinesis.stream-arn=")
    two_word_flags+=("--target.kinesis.stream-arn")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-destinations()
{
    last_command="ngrok_api_event-destinations"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-sources_create()
{
    last_command="ngrok_api_event-sources_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--subscription-id=")
    two_word_flags+=("--subscription-id")
    flags+=("--type=")
    two_word_flags+=("--type")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-sources_delete()
{
    last_command="ngrok_api_event-sources_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--subscription-id=")
    two_word_flags+=("--subscription-id")
    flags+=("--type=")
    two_word_flags+=("--type")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-sources_get()
{
    last_command="ngrok_api_event-sources_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--subscription-id=")
    two_word_flags+=("--subscription-id")
    flags+=("--type=")
    two_word_flags+=("--type")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-sources_list()
{
    last_command="ngrok_api_event-sources_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-sources_update()
{
    last_command="ngrok_api_event-sources_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--subscription-id=")
    two_word_flags+=("--subscription-id")
    flags+=("--type=")
    two_word_flags+=("--type")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-sources()
{
    last_command="ngrok_api_event-sources"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-subscriptions_create()
{
    last_command="ngrok_api_event-subscriptions_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--destination-ids=")
    two_word_flags+=("--destination-ids")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-subscriptions_delete()
{
    last_command="ngrok_api_event-subscriptions_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-subscriptions_get()
{
    last_command="ngrok_api_event-subscriptions_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-subscriptions_list()
{
    last_command="ngrok_api_event-subscriptions_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-subscriptions_update()
{
    last_command="ngrok_api_event-subscriptions_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--destination-ids=")
    two_word_flags+=("--destination-ids")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_event-subscriptions()
{
    last_command="ngrok_api_event-subscriptions"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-policies_create()
{
    last_command="ngrok_api_ip-policies_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-policies_delete()
{
    last_command="ngrok_api_ip-policies_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-policies_get()
{
    last_command="ngrok_api_ip-policies_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-policies_list()
{
    last_command="ngrok_api_ip-policies_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-policies_update()
{
    last_command="ngrok_api_ip-policies_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-policies()
{
    last_command="ngrok_api_ip-policies"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-policy-rules_create()
{
    last_command="ngrok_api_ip-policy-rules_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--action=")
    two_word_flags+=("--action")
    flags+=("--cidr=")
    two_word_flags+=("--cidr")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--ip-policy-id=")
    two_word_flags+=("--ip-policy-id")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-policy-rules_delete()
{
    last_command="ngrok_api_ip-policy-rules_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-policy-rules_get()
{
    last_command="ngrok_api_ip-policy-rules_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-policy-rules_list()
{
    last_command="ngrok_api_ip-policy-rules_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-policy-rules_update()
{
    last_command="ngrok_api_ip-policy-rules_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cidr=")
    two_word_flags+=("--cidr")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-policy-rules()
{
    last_command="ngrok_api_ip-policy-rules"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-restrictions_create()
{
    last_command="ngrok_api_ip-restrictions_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--enforced")
    flags+=("--ip-policy-ids=")
    two_word_flags+=("--ip-policy-ids")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--type=")
    two_word_flags+=("--type")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-restrictions_delete()
{
    last_command="ngrok_api_ip-restrictions_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-restrictions_get()
{
    last_command="ngrok_api_ip-restrictions_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-restrictions_list()
{
    last_command="ngrok_api_ip-restrictions_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-restrictions_update()
{
    last_command="ngrok_api_ip-restrictions_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--enforced")
    flags+=("--ip-policy-ids=")
    two_word_flags+=("--ip-policy-ids")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ip-restrictions()
{
    last_command="ngrok_api_ip-restrictions"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-addrs_create()
{
    last_command="ngrok_api_reserved-addrs_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--region=")
    two_word_flags+=("--region")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-addrs_delete()
{
    last_command="ngrok_api_reserved-addrs_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-addrs_get()
{
    last_command="ngrok_api_reserved-addrs_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-addrs_list()
{
    last_command="ngrok_api_reserved-addrs_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-addrs_update()
{
    last_command="ngrok_api_reserved-addrs_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-addrs()
{
    last_command="ngrok_api_reserved-addrs"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-domains_create()
{
    last_command="ngrok_api_reserved-domains_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--certificate-id=")
    two_word_flags+=("--certificate-id")
    flags+=("--certificate-management-policy.authority=")
    two_word_flags+=("--certificate-management-policy.authority")
    flags+=("--certificate-management-policy.private-key-type=")
    two_word_flags+=("--certificate-management-policy.private-key-type")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--domain=")
    two_word_flags+=("--domain")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--region=")
    two_word_flags+=("--region")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-domains_delete()
{
    last_command="ngrok_api_reserved-domains_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-domains_delete-certificate()
{
    last_command="ngrok_api_reserved-domains_delete-certificate"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-domains_delete-certificate-management-policy()
{
    last_command="ngrok_api_reserved-domains_delete-certificate-management-policy"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-domains_get()
{
    last_command="ngrok_api_reserved-domains_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-domains_list()
{
    last_command="ngrok_api_reserved-domains_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-domains_update()
{
    last_command="ngrok_api_reserved-domains_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--certificate-id=")
    two_word_flags+=("--certificate-id")
    flags+=("--certificate-management-policy.authority=")
    two_word_flags+=("--certificate-management-policy.authority")
    flags+=("--certificate-management-policy.private-key-type=")
    two_word_flags+=("--certificate-management-policy.private-key-type")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_reserved-domains()
{
    last_command="ngrok_api_reserved-domains"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("delete-certificate")
    commands+=("delete-certificate-management-policy")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-certificate-authorities_create()
{
    last_command="ngrok_api_ssh-certificate-authorities_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--elliptic-curve=")
    two_word_flags+=("--elliptic-curve")
    flags+=("--key-size=")
    two_word_flags+=("--key-size")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--private-key-type=")
    two_word_flags+=("--private-key-type")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-certificate-authorities_delete()
{
    last_command="ngrok_api_ssh-certificate-authorities_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-certificate-authorities_get()
{
    last_command="ngrok_api_ssh-certificate-authorities_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-certificate-authorities_list()
{
    last_command="ngrok_api_ssh-certificate-authorities_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-certificate-authorities_update()
{
    last_command="ngrok_api_ssh-certificate-authorities_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-certificate-authorities()
{
    last_command="ngrok_api_ssh-certificate-authorities"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-credentials_create()
{
    last_command="ngrok_api_ssh-credentials_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--acl=")
    two_word_flags+=("--acl")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--owner-id=")
    two_word_flags+=("--owner-id")
    flags+=("--public-key=")
    two_word_flags+=("--public-key")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-credentials_delete()
{
    last_command="ngrok_api_ssh-credentials_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-credentials_get()
{
    last_command="ngrok_api_ssh-credentials_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-credentials_list()
{
    last_command="ngrok_api_ssh-credentials_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-credentials_update()
{
    last_command="ngrok_api_ssh-credentials_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--acl=")
    two_word_flags+=("--acl")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-credentials()
{
    last_command="ngrok_api_ssh-credentials"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-host-certificates_create()
{
    last_command="ngrok_api_ssh-host-certificates_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--principals=")
    two_word_flags+=("--principals")
    flags+=("--public-key=")
    two_word_flags+=("--public-key")
    flags+=("--ssh-certificate-authority-id=")
    two_word_flags+=("--ssh-certificate-authority-id")
    flags+=("--valid-after=")
    two_word_flags+=("--valid-after")
    flags+=("--valid-until=")
    two_word_flags+=("--valid-until")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-host-certificates_delete()
{
    last_command="ngrok_api_ssh-host-certificates_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-host-certificates_get()
{
    last_command="ngrok_api_ssh-host-certificates_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-host-certificates_list()
{
    last_command="ngrok_api_ssh-host-certificates_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-host-certificates_update()
{
    last_command="ngrok_api_ssh-host-certificates_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-host-certificates()
{
    last_command="ngrok_api_ssh-host-certificates"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-user-certificates_create()
{
    last_command="ngrok_api_ssh-user-certificates_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--critical-options=")
    two_word_flags+=("--critical-options")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--extensions=")
    two_word_flags+=("--extensions")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--principals=")
    two_word_flags+=("--principals")
    flags+=("--public-key=")
    two_word_flags+=("--public-key")
    flags+=("--ssh-certificate-authority-id=")
    two_word_flags+=("--ssh-certificate-authority-id")
    flags+=("--valid-after=")
    two_word_flags+=("--valid-after")
    flags+=("--valid-until=")
    two_word_flags+=("--valid-until")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-user-certificates_delete()
{
    last_command="ngrok_api_ssh-user-certificates_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-user-certificates_get()
{
    last_command="ngrok_api_ssh-user-certificates_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-user-certificates_list()
{
    last_command="ngrok_api_ssh-user-certificates_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-user-certificates_update()
{
    last_command="ngrok_api_ssh-user-certificates_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_ssh-user-certificates()
{
    last_command="ngrok_api_ssh-user-certificates"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tls-certificates_create()
{
    last_command="ngrok_api_tls-certificates_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--certificate-pem=")
    two_word_flags+=("--certificate-pem")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--private-key-pem=")
    two_word_flags+=("--private-key-pem")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tls-certificates_delete()
{
    last_command="ngrok_api_tls-certificates_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tls-certificates_get()
{
    last_command="ngrok_api_tls-certificates_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tls-certificates_list()
{
    last_command="ngrok_api_tls-certificates_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tls-certificates_update()
{
    last_command="ngrok_api_tls-certificates_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tls-certificates()
{
    last_command="ngrok_api_tls-certificates"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("list")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tunnel-sessions_get()
{
    last_command="ngrok_api_tunnel-sessions_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tunnel-sessions_list()
{
    last_command="ngrok_api_tunnel-sessions_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tunnel-sessions_restart()
{
    last_command="ngrok_api_tunnel-sessions_restart"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tunnel-sessions_stop()
{
    last_command="ngrok_api_tunnel-sessions_stop"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tunnel-sessions_update()
{
    last_command="ngrok_api_tunnel-sessions_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tunnel-sessions()
{
    last_command="ngrok_api_tunnel-sessions"

    command_aliases=()

    commands=()
    commands+=("get")
    commands+=("list")
    commands+=("restart")
    commands+=("stop")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tunnels_get()
{
    last_command="ngrok_api_tunnels_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tunnels_list()
{
    last_command="ngrok_api_tunnels_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--before-id=")
    two_word_flags+=("--before-id")
    flags+=("--limit=")
    two_word_flags+=("--limit")
    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api_tunnels()
{
    last_command="ngrok_api_tunnels"

    command_aliases=()

    commands=()
    commands+=("get")
    commands+=("list")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_api()
{
    last_command="ngrok_api"

    command_aliases=()

    commands=()
    commands+=("abuse-reports")
    commands+=("agent-ingresses")
    commands+=("api-keys")
    commands+=("application-sessions")
    commands+=("application-users")
    commands+=("backends")
    commands+=("bot-users")
    commands+=("certificate-authorities")
    commands+=("credentials")
    commands+=("edge-modules")
    commands+=("edges")
    commands+=("endpoints")
    commands+=("event-destinations")
    commands+=("event-sources")
    commands+=("event-subscriptions")
    commands+=("ip-policies")
    commands+=("ip-policy-rules")
    commands+=("ip-restrictions")
    commands+=("reserved-addrs")
    commands+=("reserved-domains")
    commands+=("ssh-certificate-authorities")
    commands+=("ssh-credentials")
    commands+=("ssh-host-certificates")
    commands+=("ssh-user-certificates")
    commands+=("tls-certificates")
    commands+=("tunnel-sessions")
    commands+=("tunnels")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-key=")
    two_word_flags+=("--api-key")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")
    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_completion()
{
    last_command="ngrok_completion"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_config_add-api-key()
{
    last_command="ngrok_config_add-api-key"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_config_add-authtoken()
{
    last_command="ngrok_config_add-authtoken"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_config_add-connect-url()
{
    last_command="ngrok_config_add-connect-url"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_config_add-server-addr()
{
    last_command="ngrok_config_add-server-addr"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_config_check()
{
    last_command="ngrok_config_check"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_config_edit()
{
    last_command="ngrok_config_edit"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_config_upgrade()
{
    last_command="ngrok_config_upgrade"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--dry-run")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")
    flags+=("--relocate")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_config()
{
    last_command="ngrok_config"

    command_aliases=()

    commands=()
    commands+=("add-api-key")
    commands+=("add-authtoken")
    commands+=("add-connect-url")
    commands+=("add-server-addr")
    commands+=("check")
    commands+=("edit")
    commands+=("upgrade")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_credits()
{
    last_command="ngrok_credits"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_diagnose()
{
    last_command="ngrok_diagnose"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ipv6")
    flags+=("-6")
    flags+=("--region=")
    two_word_flags+=("--region")
    two_word_flags+=("-r")
    flags+=("--write-report=")
    two_word_flags+=("--write-report")
    two_word_flags+=("-w")
    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_help()
{
    last_command="ngrok_help"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_ngrok_http()
{
    last_command="ngrok_http"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--authtoken=")
    two_word_flags+=("--authtoken")
    flags+=("--basic-auth=")
    two_word_flags+=("--basic-auth")
    flags+=("--binding=")
    two_word_flags+=("--binding")
    flags+=("--cidr-allow=")
    two_word_flags+=("--cidr-allow")
    flags+=("--cidr-deny=")
    two_word_flags+=("--cidr-deny")
    flags+=("--circuit-breaker=")
    two_word_flags+=("--circuit-breaker")
    flags+=("--compression")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--domain=")
    two_word_flags+=("--domain")
    flags+=("--host-header=")
    two_word_flags+=("--host-header")
    flags+=("--inspect=")
    two_word_flags+=("--inspect")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--mutual-tls-cas=")
    two_word_flags+=("--mutual-tls-cas")
    flags+=("--oauth=")
    two_word_flags+=("--oauth")
    flags+=("--oauth-allow-domain=")
    two_word_flags+=("--oauth-allow-domain")
    flags+=("--oauth-allow-email=")
    two_word_flags+=("--oauth-allow-email")
    flags+=("--oauth-client-id=")
    two_word_flags+=("--oauth-client-id")
    flags+=("--oauth-client-secret=")
    two_word_flags+=("--oauth-client-secret")
    flags+=("--oauth-scope=")
    two_word_flags+=("--oauth-scope")
    flags+=("--oidc=")
    two_word_flags+=("--oidc")
    flags+=("--oidc-client-id=")
    two_word_flags+=("--oidc-client-id")
    flags+=("--oidc-client-secret=")
    two_word_flags+=("--oidc-client-secret")
    flags+=("--oidc-scope=")
    two_word_flags+=("--oidc-scope")
    flags+=("--proxy-proto=")
    two_word_flags+=("--proxy-proto")
    flags+=("--request-header-add=")
    two_word_flags+=("--request-header-add")
    flags+=("--request-header-remove=")
    two_word_flags+=("--request-header-remove")
    flags+=("--response-header-add=")
    two_word_flags+=("--response-header-add")
    flags+=("--response-header-remove=")
    two_word_flags+=("--response-header-remove")
    flags+=("--traffic-policy-file=")
    two_word_flags+=("--traffic-policy-file")
    flags+=("--ua-filter-allow=")
    two_word_flags+=("--ua-filter-allow")
    flags+=("--ua-filter-deny=")
    two_word_flags+=("--ua-filter-deny")
    flags+=("--upstream-protocol=")
    two_word_flags+=("--upstream-protocol")
    flags+=("--upstream-tls-verify")
    flags+=("--upstream-tls-verify-cas=")
    two_word_flags+=("--upstream-tls-verify-cas")
    flags+=("--url=")
    two_word_flags+=("--url")
    flags+=("--verify-webhook=")
    two_word_flags+=("--verify-webhook")
    flags+=("--verify-webhook-secret=")
    two_word_flags+=("--verify-webhook-secret")
    flags+=("--websocket-tcp-converter")
    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_service()
{
    last_command="ngrok_service"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_start()
{
    last_command="ngrok_start"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("--authtoken=")
    two_word_flags+=("--authtoken")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")
    flags+=("--none")
    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_tcp()
{
    last_command="ngrok_tcp"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--authtoken=")
    two_word_flags+=("--authtoken")
    flags+=("--binding=")
    two_word_flags+=("--binding")
    flags+=("--cidr-allow=")
    two_word_flags+=("--cidr-allow")
    flags+=("--cidr-deny=")
    two_word_flags+=("--cidr-deny")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--proxy-proto=")
    two_word_flags+=("--proxy-proto")
    flags+=("--remote-addr=")
    two_word_flags+=("--remote-addr")
    flags+=("--traffic-policy-file=")
    two_word_flags+=("--traffic-policy-file")
    flags+=("--url=")
    two_word_flags+=("--url")
    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_tls()
{
    last_command="ngrok_tls"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--authtoken=")
    two_word_flags+=("--authtoken")
    flags+=("--binding=")
    two_word_flags+=("--binding")
    flags+=("--cidr-allow=")
    two_word_flags+=("--cidr-allow")
    flags+=("--cidr-deny=")
    two_word_flags+=("--cidr-deny")
    flags+=("--crt=")
    two_word_flags+=("--crt")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--domain=")
    two_word_flags+=("--domain")
    flags+=("--key=")
    two_word_flags+=("--key")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--mutual-tls-cas=")
    two_word_flags+=("--mutual-tls-cas")
    flags+=("--proxy-proto=")
    two_word_flags+=("--proxy-proto")
    flags+=("--terminate-at=")
    two_word_flags+=("--terminate-at")
    flags+=("--traffic-policy-file=")
    two_word_flags+=("--traffic-policy-file")
    flags+=("--upstream-tls-verify")
    flags+=("--upstream-tls-verify-cas=")
    two_word_flags+=("--upstream-tls-verify-cas")
    flags+=("--url=")
    two_word_flags+=("--url")
    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_tunnel()
{
    last_command="ngrok_tunnel"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--authtoken=")
    two_word_flags+=("--authtoken")
    flags+=("--crt=")
    two_word_flags+=("--crt")
    flags+=("--description=")
    two_word_flags+=("--description")
    flags+=("--inspect=")
    two_word_flags+=("--inspect")
    flags+=("--key=")
    two_word_flags+=("--key")
    flags+=("--label=")
    two_word_flags+=("--label")
    flags+=("--log=")
    two_word_flags+=("--log")
    flags+=("--log-format=")
    two_word_flags+=("--log-format")
    flags+=("--log-level=")
    two_word_flags+=("--log-level")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")
    flags+=("--mutual-tls-cas=")
    two_word_flags+=("--mutual-tls-cas")
    flags+=("--proxy-proto=")
    two_word_flags+=("--proxy-proto")
    flags+=("--upstream-protocol=")
    two_word_flags+=("--upstream-protocol")
    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_update()
{
    last_command="ngrok_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--channel=")
    two_word_flags+=("--channel")
    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_version()
{
    last_command="ngrok_version"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_ngrok_root_command()
{
    last_command="ngrok"

    command_aliases=()

    commands=()
    commands+=("api")
    commands+=("completion")
    commands+=("config")
    commands+=("credits")
    commands+=("diagnose")
    commands+=("help")
    commands+=("http")
    commands+=("service")
    commands+=("start")
    commands+=("tcp")
    commands+=("tls")
    commands+=("tunnel")
    commands+=("update")
    commands+=("version")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--metadata=")
    two_word_flags+=("--metadata")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_ngrok()
{
    local cur prev words cword split
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __ngrok_init_completion -n "=" || return
    fi

    local c=0
    local flag_parsing_disabled=
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("ngrok")
    local command_aliases=()
    local must_have_one_flag=()
    local must_have_one_noun=()
    local has_completion_function=""
    local last_command=""
    local nouns=()
    local noun_aliases=()

    __ngrok_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_ngrok ngrok
else
    complete -o default -o nospace -F __start_ngrok ngrok
fi

# ex: ts=4 sw=4 et filetype=sh
