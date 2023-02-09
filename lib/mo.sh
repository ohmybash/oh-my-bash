#! bash oh-my-bash.module
#
#/ Mo is a mustache template rendering software written in bash.  It inserts
#/ environment variables into templates.
#/
#/ Simply put, mo will change {{VARIABLE}} into the value of that
#/ environment variable.  You can use {{#VARIABLE}}content{{/VARIABLE}} to
#/ conditionally display content or iterate over the values of an array.
#/
#/ Learn more about mustache templates at https://mustache.github.io/
#/
#/ Simple usage:
#/
#/    mo [--false] [--help] [--source=FILE] filenames...
#/
#/ --false       - Treat the string "false" as empty for conditionals.
#/ --help        - This message.
#/ --source=FILE - Load FILE into the environment before processing templates.
#
# Mo is under a MIT style licence with an additional non-advertising clause.
# See LICENSE.md for the full text.
#
# This is open source!  Please feel free to contribute.
#
# https://github.com/tests-always-included/mo


# Public: Template parser function.  Writes templates to stdout.
#
# $0            - Name of the mo file, used for getting the help message.
# --false       - Treat "false" as an empty value.  You may set the
#                 MO_FALSE_IS_EMPTY environment variable instead to a non-empty
#                 value to enable this behavior.
# --help        - Display a help message.
# --source=FILE - Source a file into the environment before processint
#                 template files.
# --            - Used to indicate the end of options.  You may optionally
#                 use this when filenames may start with two hyphens.
# $@            - Filenames to parse.
#
# Mo uses the following environment variables:
#
# MO_FALSE_IS_EMPTY   - When set to a non-empty value, the string "false"
#                       will be treated as an empty value for the purposes
#                       of conditionals.
# MO_ORIGINAL_COMMAND - Used to find the `mo` program in order to generate
#                       a help message.
#
# Returns nothing.
function mo {
    # This function executes in a subshell so IFS is reset.
    # Namespace this variable so we don't conflict with desired values.
    local moContent f2source files doubleHyphens

    IFS=$' \n\t'
    files=()
    doubleHyphens=false

    if [[ $# -gt 0 ]]; then
        for arg in "$@"; do
            if $doubleHyphens; then
                # After we encounter two hyphens together, all the rest
                # of the arguments are files.
                files=("${files[@]}" "$arg")
            else
                case "$arg" in
                    -h|--h|--he|--hel|--help|-\?)
                        _moUsage "$0"
                        exit 0
                        ;;

                    --false)
                        # shellcheck disable=SC2030
                        MO_FALSE_IS_EMPTY=true
                        ;;

                    --source=*)
                        f2source="${arg#--source=}"

                        if [[ -f "$f2source" ]]; then
                            # shellcheck disable=SC1090
                            . "$f2source"
                        else
                            echo "No such file: $f2source" >&2
                            exit 1
                        fi
                        ;;

                    --)
                        # Set a flag indicating we've encountered double hyphens
                        doubleHyphens=true
                        ;;

                    *)
                        # Every arg that is not a flag or a option should be a file
                        files=("${files[@]}" "$arg")
                        ;;
                esac
            fi
        done
    fi

    _moGetContent moContent "${files[@]}"
    _moParse "$moContent" "" true
}


# Internal: Scan content until the right end tag is found.  Creates an array
# with the following members:
#
#   [0] = Content before end tag
#   [1] = End tag (complete tag)
#   [2] = Content after end tag
#
# Everything using this function uses the "standalone tags" logic.
#
# $1 - Name of variable for the array
# $2 - Content
# $3 - Name of end tag
# $4 - If -z, do standalone tag processing before finishing
#
# Returns nothing.
function _moFindEndTag {
    local content remaining scanned standaloneBytes tag

    #: Find open tags
    scanned=""
    _moSplit content "$2" '{{' '}}'

    while [[ "${#content[@]}" -gt 1 ]]; do
        _moTrimWhitespace tag "${content[1]}"

        #: Restore content[1] before we start using it
        content[1]='{{'"${content[1]}"'}}'

        case $tag in
            '#'* | '^'*)
                #: Start another block
                scanned="${scanned}${content[0]}${content[1]}"
                _moTrimWhitespace tag "${tag:1}"
                _moFindEndTag content "${content[2]}" "$tag" "loop"
                scanned="${scanned}${content[0]}${content[1]}"
                remaining=${content[2]}
                ;;

            '/'*)
                #: End a block - could be ours
                _moTrimWhitespace tag "${tag:1}"
                scanned="$scanned${content[0]}"

                if [[ "$tag" == "$3" ]]; then
                    #: Found our end tag
                    if [[ -z "${4-}" ]] && _moIsStandalone standaloneBytes "$scanned" "${content[2]}" true; then
                        #: This is also a standalone tag - clean up whitespace
                        #: and move those whitespace bytes to the "tag" element
                        standaloneBytes=( $standaloneBytes )
                        content[1]="${scanned:${standaloneBytes[0]}}${content[1]}${content[2]:0:${standaloneBytes[1]}}"
                        scanned="${scanned:0:${standaloneBytes[0]}}"
                        content[2]="${content[2]:${standaloneBytes[1]}}"
                    fi

                    local "$1" && _moIndirectArray "$1" "$scanned" "${content[1]}" "${content[2]}"
                    return 0
                fi

                scanned="$scanned${content[1]}"
                remaining=${content[2]}
                ;;

            *)
                #: Ignore all other tags
                scanned="${scanned}${content[0]}${content[1]}"
                remaining=${content[2]}
                ;;
        esac

        _moSplit content "$remaining" '{{' '}}'
    done

    #: Did not find our closing tag
    scanned="$scanned${content[0]}"
    local "$1" && _moIndirectArray "$1" "${scanned}" "" ""
}


# Internal: Find the first index of a substring.  If not found, sets the
# index to -1.
#
# $1 - Destination variable for the index
# $2 - Haystack
# $3 - Needle
#
# Returns nothing.
function _moFindString {
    local pos string

    string=${2%%$3*}
    [[ "$string" == "$2" ]] && pos=-1 || pos=${#string}
    local "$1" && _moIndirect "$1" "$pos"
}


# Internal: Generate a dotted name based on current context and target name.
#
# $1 - Target variable to store results
# $2 - Context name
# $3 - Desired variable name
#
# Returns nothing.
function _moFullTagName {
    if [[ -z "${2-}" ]] || [[ "$2" == *.* ]]; then
        local "$1" && _moIndirect "$1" "$3"
    else
        local "$1" && _moIndirect "$1" "${2}.${3}"
    fi
}


# Internal: Fetches the content to parse into a variable.  Can be a list of
# partials for files or the content from stdin.
#
# $1   - Variable name to assign this content back as
# $2-@ - File names (optional)
#
# Returns nothing.
function _moGetContent {
    local content filename target

    target=$1
    shift
    if [[ "${#@}" -gt 0 ]]; then
        content=""

        for filename in "$@"; do
            #: This is so relative paths work from inside template files
            content="$content"'{{>'"$filename"'}}'
        done
    else
        _moLoadFile content /dev/stdin
    fi

    local "$target" && _moIndirect "$target" "$content"
}


# Internal: Indent a string, placing the indent at the beginning of every
# line that has any content.
#
# $1 - Name of destination variable to get an array of lines
# $2 - The indent string
# $3 - The string to reindent
#
# Returns nothing.
function _moIndentLines {
    local content fragment len posN posR result trimmed

    result=""
    len=$((${#3} - 1))

    #: This removes newline and dot from the workaround in _moPartial
    content="${3:0:$len}"

    if [[ -z "${2-}" ]]; then
        local "$1" && _moIndirect "$1" "$content"

        return 0
    fi

    _moFindString posN "$content" $'\n'
    _moFindString posR "$content" $'\r'

    while [[ "$posN" -gt -1 ]] || [[ "$posR" -gt -1 ]]; do
        if [[ "$posN" -gt -1 ]]; then
            fragment="${content:0:$posN + 1}"
            content=${content:$posN + 1}
        else
            fragment="${content:0:$posR + 1}"
            content=${content:$posR + 1}
        fi

        _moTrimChars trimmed "$fragment" false true " " $'\t' $'\n' $'\r'

        if [[ -n "$trimmed" ]]; then
            fragment="$2$fragment"
        fi

        result="$result$fragment"
        _moFindString posN "$content" $'\n'
        _moFindString posR "$content" $'\r'
    done

    _moTrimChars trimmed "$content" false true " " $'\t'

    if [[ -n "$trimmed" ]]; then
        content="$2$content"
    fi

    result="$result$content"

    local "$1" && _moIndirect "$1" "$result"
}


# Internal: Send a variable up to the parent of the caller of this function.
#
# $1 - Variable name
# $2 - Value
#
# Examples
#
#   callFunc () {
#       local "$1" && _moIndirect "$1" "the value"
#   }
#   callFunc dest
#   echo "$dest"  # writes "the value"
#
# Returns nothing.
function _moIndirect {
    unset -v "$1"
    printf -v "$1" '%s' "$2"
}


# Internal: Send an array as a variable up to caller of a function
#
# $1   - Variable name
# $2-@ - Array elements
#
# Examples
#
#   callFunc () {
#       local myArray=(one two three)
#       local "$1" && _moIndirectArray "$1" "${myArray[@]}"
#   }
#   callFunc dest
#   echo "${dest[@]}" # writes "one two three"
#
# Returns nothing.
function _moIndirectArray {
    unset -v "$1"

    # IFS must be set to a string containing space or unset in order for
    # the array slicing to work regardless of the current IFS setting on
    # bash 3.  This is detailed further at
    # https://github.com/fidian/gg-core/pull/7
    eval "$(printf "IFS= %s=(\"\${@:2}\") IFS=%q" "$1" "$IFS")"
}


# Internal: Determine if a given environment variable exists and if it is
# an array.
#
# $1 - Name of environment variable
#
# Be extremely careful.  Even if strict mode is enabled, it is not honored
# in newer versions of Bash.  Any errors that crop up here will not be
# caught automatically.
#
# Examples
#
#   var=(abc)
#   if _moIsArray var; then
#      echo "This is an array"
#      echo "Make sure you don't accidentally use \$var"
#   fi
#
# Returns 0 if the name is not empty, 1 otherwise.
function _moIsArray {
    # Namespace this variable so we don't conflict with what we're testing.
    local moTestResult

    moTestResult=$(declare -p "$1" 2>/dev/null) || return 1
    [[ "${moTestResult:0:10}" == "declare -a" ]] && return 0
    [[ "${moTestResult:0:10}" == "declare -A" ]] && return 0

    return 1
}


# Internal: Determine if the given name is a defined function.
#
# $1 - Function name to check
#
# Be extremely careful.  Even if strict mode is enabled, it is not honored
# in newer versions of Bash.  Any errors that crop up here will not be
# caught automatically.
#
# Examples
#
#   moo () {
#       echo "This is a function"
#   }
#   if _moIsFunction moo; then
#       echo "moo is a defined function"
#   fi
#
# Returns 0 if the name is a function, 1 otherwise.
function _moIsFunction {
    local functionList functionName

    functionList=$(declare -F)
    functionList=( ${functionList//declare -f /} )

    for functionName in "${functionList[@]}"; do
        if [[ "$functionName" == "$1" ]]; then
            return 0
        fi
    done

    return 1
}


# Internal: Determine if the tag is a standalone tag based on whitespace
# before and after the tag.
#
# Passes back a string containing two numbers in the format "BEFORE AFTER"
# like "27 10".  It indicates the number of bytes remaining in the "before"
# string (27) and the number of bytes to trim in the "after" string (10).
# Useful for string manipulation:
#
# $1 - Variable to set for passing data back
# $2 - Content before the tag
# $3 - Content after the tag
# $4 - true/false: is this the beginning of the content?
#
# Examples
#
#   _moIsStandalone RESULT "$before" "$after" false || return 0
#   RESULT_ARRAY=( $RESULT )
#   echo "${before:0:${RESULT_ARRAY[0]}}...${after:${RESULT_ARRAY[1]}}"
#
# Returns nothing.
function _moIsStandalone {
    local afterTrimmed beforeTrimmed char

    _moTrimChars beforeTrimmed "$2" false true " " $'\t'
    _moTrimChars afterTrimmed "$3" true false " " $'\t'
    char=$((${#beforeTrimmed} - 1))
    char=${beforeTrimmed:$char}

    if [[ "$char" != $'\n' ]] && [[ "$char" != $'\r' ]]; then
        if [[ -n "$char" ]] || ! $4; then
            return 1
        fi
    fi

    char=${afterTrimmed:0:1}

    if [[ "$char" != $'\n' ]] && [[ "$char" != $'\r' ]] && [[ -n "$char" ]]; then
        return 2
    fi

    if [[ "$char" == $'\r' ]] && [[ "${afterTrimmed:1:1}" == $'\n' ]]; then
        char="$char"$'\n'
    fi

    local "$1" && _moIndirect "$1" "$((${#beforeTrimmed})) $((${#3} + ${#char} - ${#afterTrimmed}))"
}


# Internal: Join / implode an array
#
# $1    - Variable name to receive the joined content
# $2    - Joiner
# $3-$* - Elements to join
#
# Returns nothing.
function _moJoin {
    local joiner part result target

    target=$1
    joiner=$2
    result=$3
    shift 3

    for part in "$@"; do
        result="$result$joiner$part"
    done

    local "$target" && _moIndirect "$target" "$result"
}


# Internal: Read a file into a variable.
#
# $1 - Variable name to receive the file's content
# $2 - Filename to load
#
# Returns nothing.
function _moLoadFile {
    local content len

    # The subshell removes any trailing newlines.  We forcibly add
    # a dot to the content to preserve all newlines.
    # TODO: remove cat and replace with read loop?

    content=$(cat -- "$2"; echo '.')
    len=$((${#content} - 1))
    content=${content:0:$len}  # Remove last dot

    local "$1" && _moIndirect "$1" "$content"
}


# Internal: Process a chunk of content some number of times.  Writes output
# to stdout.
#
# $1   - Content to parse repeatedly
# $2   - Tag prefix (context name)
# $3-@ - Names to insert into the parsed content
#
# Returns nothing.
function _moLoop {
    local content context contextBase

    content=$1
    contextBase=$2
    shift 2

    while [[ "${#@}" -gt 0 ]]; do
        _moFullTagName context "$contextBase" "$1"
        _moParse "$content" "$context" false
        shift
    done
}


# Internal: Parse a block of text, writing the result to stdout.
#
# $1 - Block of text to change
# $2 - Current name (the variable NAME for what {{.}} means)
# $3 - true when no content before this, false otherwise
#
# Returns nothing.
function _moParse {
    # Keep naming variables mo* here to not overwrite needed variables
    # used in the string replacements
    local moBlock moContent moCurrent moIsBeginning moTag

    moCurrent=$2
    moIsBeginning=$3

    # Find open tags
    _moSplit moContent "$1" '{{' '}}'

    while [[ "${#moContent[@]}" -gt 1 ]]; do
        _moTrimWhitespace moTag "${moContent[1]}"

        case $moTag in
            '#'*)
                # Loop, if/then, or pass content through function
                # Sets context
                _moStandaloneAllowed moContent "${moContent[@]}" "$moIsBeginning"
                _moTrimWhitespace moTag "${moTag:1}"
                _moFindEndTag moBlock "$moContent" "$moTag"
                _moFullTagName moTag "$moCurrent" "$moTag"

                if _moTest "$moTag"; then
                    # Show / loop / pass through function
                    if _moIsFunction "$moTag"; then
                        #: TODO: Consider piping the output to _moGetContent
                        #: so the lambda does not execute in a subshell?
                        moContent=$($moTag "${moBlock[0]}")
                        _moParse "$moContent" "$moCurrent" false
                        moContent="${moBlock[2]}"
                    elif _moIsArray "$moTag"; then
                        eval "_moLoop \"\${moBlock[0]}\" \"$moTag\" \"\${!${moTag}[@]}\""
                    else
                        _moParse "${moBlock[0]}" "$moCurrent" false
                    fi
                fi

                moContent="${moBlock[2]}"
                ;;

            '>'*)
                # Load partial - get name of file relative to cwd
                _moPartial moContent "${moContent[@]}" "$moIsBeginning" "$moCurrent"
                ;;

            '/'*)
                # Closing tag - If hit in this loop, we simply ignore
                # Matching tags are found in _moFindEndTag
                _moStandaloneAllowed moContent "${moContent[@]}" "$moIsBeginning"
                ;;

            '^'*)
                # Display section if named thing does not exist
                _moStandaloneAllowed moContent "${moContent[@]}" "$moIsBeginning"
                _moTrimWhitespace moTag "${moTag:1}"
                _moFindEndTag moBlock "$moContent" "$moTag"
                _moFullTagName moTag "$moCurrent" "$moTag"

                if ! _moTest "$moTag"; then
                    _moParse "${moBlock[0]}" "$moCurrent" false "$moCurrent"
                fi

                moContent="${moBlock[2]}"
                ;;

            '!'*)
                # Comment - ignore the tag content entirely
                # Trim spaces/tabs before the comment
                _moStandaloneAllowed moContent "${moContent[@]}" "$moIsBeginning"
                ;;

            .)
                # Current content (environment variable or function)
                _moStandaloneDenied moContent "${moContent[@]}"
                _moShow "$moCurrent" "$moCurrent"
                ;;

            '=')
                # Change delimiters
                # Any two non-whitespace sequences separated by whitespace.
                # TODO
                _moStandaloneAllowed moContent "${moContent[@]}" "$moIsBeginning"
                ;;

            '{'*)
                # Unescaped - split on }}} not }}
                _moStandaloneDenied moContent "${moContent[@]}"
                moContent="${moTag:1}"'}}'"$moContent"
                _moSplit moContent "$moContent" '}}}'
                _moTrimWhitespace moTag "${moContent[0]}"
                _moFullTagName moTag "$moCurrent" "$moTag"
                moContent=${moContent[1]}

                # Now show the value
                _moShow "$moTag" "$moCurrent"
                ;;

            '&'*)
                # Unescaped
                _moStandaloneDenied moContent "${moContent[@]}"
                _moTrimWhitespace moTag "${moTag:1}"
                _moFullTagName moTag "$moCurrent" "$moTag"
                _moShow "$moTag" "$moCurrent"
                ;;

            *)
                # Normal environment variable or function call
                _moStandaloneDenied moContent "${moContent[@]}"
                _moFullTagName moTag "$moCurrent" "$moTag"
                _moShow "$moTag" "$moCurrent"
                ;;
        esac

        moIsBeginning=false
        _moSplit moContent "$moContent" '{{' '}}'
    done

    echo -n "${moContent[0]}"
}


# Internal: Process a partial.
#
# Indentation should be applied to the entire partial
#
# Prefix all variables.
#
# $1 - Name of destination "content" variable.
# $2 - Content before the tag that was not yet written
# $3 - Tag content
# $4 - Content after the tag
# $5 - true/false: is this the beginning of the content?
# $6 - Current context name
#
# Returns nothing.
function _moPartial {
    # Namespace variables here to prevent conflicts.
    local moContent moFilename moIndent moPartial moStandalone

    if _moIsStandalone moStandalone "$2" "$4" "$5"; then
        moStandalone=( $moStandalone )
        echo -n "${2:0:${moStandalone[0]}}"
        moIndent=${2:${moStandalone[0]}}
        moContent=${4:${moStandalone[1]}}
    else
        moIndent=""
        echo -n "$2"
        moContent=$4
    fi

    _moTrimWhitespace moFilename "${3:1}"

    # Execute in subshell to preserve current cwd and environment
    (
        # TODO:  Remove dirname and use a function instead
        cd "$(dirname -- "$moFilename")" || exit 1
        _moIndentLines moPartial "$moIndent" "$(
            _moLoadFile moPartial "${moFilename##*/}"

            # Fix bash handling of subshells
            # The extra dot is removed in _moIndentLines
            echo -n "${moPartial}."
        )"
        _moParse "$moPartial" "$6" true
    )

    local "$1" && _moIndirect "$1" "$moContent"
}


# Internal: Show an environment variable or the output of a function to
# stdout.
#
# Limit/prefix any variables used.
#
# $1 - Name of environment variable or function
# $2 - Current context
#
# Returns nothing.
function _moShow {
    # Namespace these variables
    local moJoined moNameParts

    if _moIsFunction "$1"; then
        CONTENT=$($1 "")
        _moParse "$CONTENT" "$2" false
        return 0
    fi

    _moSplit moNameParts "$1" "."

    if [[ -z "${moNameParts[1]}" ]]; then
        if _moIsArray "$1"; then
            eval _moJoin moJoined "," "\${$1[@]}"
            echo -n "$moJoined"
        else
            echo -n "${!1}"
        fi
    else
        # Further subindexes are disallowed
        eval "echo -n \"\${${moNameParts[0]}[${moNameParts[1]%%.*}]}\""
    fi
}


# Internal: Split a larger string into an array.
#
# $1 - Destination variable
# $2 - String to split
# $3 - Starting delimiter
# $4 - Ending delimiter (optional)
#
# Returns nothing.
function _moSplit {
    local pos result

    result=( "$2" )
    _moFindString pos "${result[0]}" "$3"

    if [[ "$pos" -ne -1 ]]; then
        # The first delimiter was found
        result[1]=${result[0]:$pos + ${#3}}
        result[0]=${result[0]:0:$pos}

        if [[ -n "${4-}" ]]; then
            _moFindString pos "${result[1]}" "$4"

            if [[ "$pos" -ne -1 ]]; then
                # The second delimiter was found
                result[2]="${result[1]:$pos + ${#4}}"
                result[1]="${result[1]:0:$pos}"
            fi
        fi
    fi

    local "$1" && _moIndirectArray "$1" "${result[@]}"
}


# Internal: Handle the content for a standalone tag.  This means removing
# whitespace (not newlines) before a tag and whitespace and a newline after
# a tag.  That is, assuming, that the line is otherwise empty.
#
# $1 - Name of destination "content" variable.
# $2 - Content before the tag that was not yet written
# $3 - Tag content (not used)
# $4 - Content after the tag
# $5 - true/false: is this the beginning of the content?
#
# Returns nothing.
function _moStandaloneAllowed {
    local bytes

    if _moIsStandalone bytes "$2" "$4" "$5"; then
        bytes=( $bytes )
        echo -n "${2:0:${bytes[0]}}"
        local "$1" && _moIndirect "$1" "${4:${bytes[1]}}"
    else
        echo -n "$2"
        local "$1" && _moIndirect "$1" "$4"
    fi
}


# Internal: Handle the content for a tag that is never "standalone".  No
# adjustments are made for newlines and whitespace.
#
# $1 - Name of destination "content" variable.
# $2 - Content before the tag that was not yet written
# $3 - Tag content (not used)
# $4 - Content after the tag
#
# Returns nothing.
function _moStandaloneDenied {
    echo -n "$2"
    local "$1" && _moIndirect "$1" "$4"
}


# Internal: Determines if the named thing is a function or if it is a
# non-empty environment variable.  When MO_FALSE_IS_EMPTY is set to a
# non-empty value, then "false" is also treated is an empty value.
#
# Do not use variables without prefixes here if possible as this needs to
# check if any name exists in the environment
#
# $1                - Name of environment variable or function
# $2                - Current value (our context)
# MO_FALSE_IS_EMPTY - When set to a non-empty value, this will say the
#                     string value "false" is empty.
#
# Returns 0 if the name is not empty, 1 otherwise.  When MO_FALSE_IS_EMPTY
# is set, this returns 1 if the name is "false".
function _moTest {
    # Test for functions
    _moIsFunction "$1" && return 0

    if _moIsArray "$1"; then
        # Arrays must have at least 1 element
        eval "[[ \"\${#${1}[@]}\" -gt 0 ]]" && return 0
    else
        # If MO_FALSE_IS_EMPTY is set, then return 1 if the value of
        # the variable is "false".
        # shellcheck disable=SC2031
        [[ -n "${MO_FALSE_IS_EMPTY-}" ]] && [[ "${!1-}" == "false" ]] && return 1

        # Environment variables must not be empty
        [[ -n "${!1}" ]] && return 0
    fi

    return 1
}


# Internal: Trim the leading whitespace only.
#
# $1   - Name of destination variable
# $2   - The string
# $3   - true/false - trim front?
# $4   - true/false - trim end?
# $5-@ - Characters to trim
#
# Returns nothing.
function _moTrimChars {
    local back current front last target varName

    target=$1
    current=$2
    front=$3
    back=$4
    last=""
    shift 4 # Remove target, string, trim front flag, trim end flag

    while [[ "$current" != "$last" ]]; do
        last=$current

        for varName in "$@"; do
            $front && current="${current/#$varName}"
            $back && current="${current/%$varName}"
        done
    done

    local "$target" && _moIndirect "$target" "$current"
}


# Internal: Trim leading and trailing whitespace from a string.
#
# $1 - Name of variable to store trimmed string
# $2 - The string
#
# Returns nothing.
function _moTrimWhitespace {
    local result

    _moTrimChars result "$2" true true $'\r' $'\n' $'\t' " "
    local "$1" && _moIndirect "$1" "$result"
}


# Internal: Displays the usage for mo.  Pulls this from the file that
# contained the `mo` function.  Can only work when the right filename
# comes is the one argument, and that only happens when `mo` is called
# with `$0` set to this file.
#
# $1 - Filename that has the help message
#
# Returns nothing.
function _moUsage {
    grep '^#/' "${MO_ORIGINAL_COMMAND}" | cut -c 4-
}


# Save the original command's path for usage later
MO_ORIGINAL_COMMAND="$(cd "${BASH_SOURCE[0]%/*}" || exit 1; pwd)/${BASH_SOURCE[0]##*/}"

# If sourced, load all functions.
# If executed, perform the actions as expected.
if [[ "$0" == "${BASH_SOURCE[0]}" ]] || [[ -z "${BASH_SOURCE[0]}" ]]; then
    mo "$@"
fi
