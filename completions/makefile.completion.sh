#! bash oh-my-bash.module
#
# Makefile Completion with Descriptions
# -------------------------------------
#
# Collects targets and variable names from Makefiles and included files in the
# current directory and provides tab completion with descriptions on repeated
# Tab presses.
#
# Requirements:
#  - grep
#  - awk
#  - sed
#  - column
#  - bash (with shopt support)
#  - terminal that supports ANSI escape codes for colorization
#
# Usage:
#  - Press Tab once to complete targets
#  - Press Tab twice to see target descriptions
#
# Example Makefile Structure:
#
#  Makefile
#  ├── scripts
#  │   ├── ai.mk
#  │   └── ...
#
#
# Makefile content:
# _____________________________________________________
#
#  include scripts/usage.mk
#  include scripts/ai.mk
#  include scripts/go.mk
# _____________________________________________________
#
#
# Included content:
# _____________________________________________________
#
#  ## AI-related tasks
#  .PHONY: ⚙️  # make all non-file targets phony
#
#  ai-init: ⚙️  ## Initialize AI environment
#     @echo "Setting up AI environment..."
#
#  ai-files: ⚙️  ## Ensure AI agent files match provider-recommended structure
#     @echo "Checking AI agent files..."
#
#  # ... other targets ...
# _____________________________________________________
#
#
# Example Output:
# _____________________________________________________
#
# 17:52:16 user@machine myrepo ±|main ✗|→ make ai       👈️ 1st tab press
# ai_chat=        ai-files        ai-init               👈️ short completion list
# 17:52:16 user@machine myrepo ±|main ✗|→ make ai░      👈️ 2nd tab press (adds repeat indicator)
# --Makefile--                                             and shows descriptions (if defined)
# --scripts/usage.mk--
# --scripts/ai.mk--
#    ai-init                Initialize AI environment
#    ai-files               Ensure AI agent files match provider-recommended structure
#    ai-review              Use AI to review recent changes in the repository
#    ai-tech-only           Use AI to identify and remove of non-technical content
#    ai-update-docs         Use AI to update documentation based on code changes
#    ai_chat=code chat                                  👈️ also shows variable values
# --scripts/go.mk--
#
# ai_chat=        ai-files        ai-init               👈️ still short completion list
# 17:52:16 user@machine myrepo ±|main ✗|→ make ai
# _____________________________________________________
#
# Output will be colorized using ANSI escape codes.


# Bash Style Guide
# ----------------
# This file uses an opinionated Bash style for better readability and maintainability.
#
# General Guidelines:
#  - Use '_omb_completion_' prefix for function/variable names to avoid conflicts
#  - Use '_omb_term_*' variables for terminal colors
#  - Use 'local' variables where possible
#  - Return early from functions to avoid deep nesting
#
# Human-Readable Bash:
#  - Use 'test <condition>' for conditionals instead of clumsy '[[ ... ]]'.
#    Always prefer plain English keywords for best readability.
#  - Break before 'then', 'do', 'else' to avoid complicated semi-colon lines
#  - With 'then' and 'else' on new lines, write commands directly following them.
#    This provides best readability for short if-then-else blocks, e.g.:
#
#     if test "$condition"
#     then command1
#     else command2
#     fi
#
#  - Indent with 5 spaces for best alignment and readability. This matches best
#    with the 'then' and 'else' blocks on new lines, e.g.:
#
#     if test "$condition"
#     then command1
#          command2
#     else command3
#          command3
#     fi
#
#  - Use 'case' statements for multi-way branching instead of 'if-elif-else';
#    Use opening and closing parentheses for case patterns and put pattern at
#    the beginning of the line:
#
#     case "$var" in
#     (pattern1)  command1;;
#     (pattern2)  command2;;
#     (*)         command3;;
#     esac
#
#  - Use 'command <cmd>' to avoid alias/function conflicts
#  - Use 'shopt' to set/unset shell options as needed
#  - Use 'awk' for text processing where possible for better performance,
#    readability, and flexibility. Break the awk script into multiple lines for
#    better readability:
#    command awk -F '<field-separator>' -v var="value" '
#    function <name>(<args>) { <body> }
#    BEGIN { ... }            # if needed
#    <pattern> { <actions> }  # describe block
#    ' <input-file>
#

# Find included Makefile paths (.mk) from given Makefiles.
_omb_completion_makefile_find_includes() {
     shopt -u nullglob
     shopt -s nocaseglob
     local makefiles="$*"
     if test -z "$makefiles"
     then makefiles="*makefile"
     fi
     command awk '/^include[[:space:]]/ {print $2;}' $makefiles 2>/dev/null
}

# AWK command with args for colorized output and Makefile parsing.
# This is the main AWK program, with helper functions for parsing comments,
# variable assignments, and targets declarations. By default, it skips recipe
# lines and full-line comments starting with "#".
_omb_completion_makefile_awk() {
     local red=$_omb_term_red
     local grn=$_omb_term_green
     local blu=$_omb_term_blue
     local gry=$_omb_term_gray
     local cyn=$_omb_term_cyan
     local pur=$_omb_term_purple
     local rst=$_omb_term_reset
     local query="${COMP_WORDS[COMP_CWORD]}"
     command awk \
     -v red="$red" -v grn="$grn" -v blu="$blu" -v gry="$gry" -v cyn="$cyn" -v pur="$pur" -v rst="$rst" \
     -v TARGET="TARGET" -v VAR="VAR" -v FLAG="FLAG" -v OPT="OPT" \
     -v query="^$query" \
     -v exp_var='[a-zA-Z_][a-zA-Z0-9_]*' \
     -v exp_assign='^[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*[+:?]?=' \
     -v exp_export='^export[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*' \
     -v exp_target='^[a-z0-9_!-]+:.*' \
     -v exp_header='^---- .* ----$' \
     -v exp_comment='^#' \
     -v exp_recipe='^\t' \
     -v fs_assign='[[:space:]]*[+:?]?=[[:space:]]*|[[:space:]]*#+[[:space:]]*' \
     -v fs_target=':[[:space:]]*|[[:space:]]*#+[[:space:]]*' \
     -v fs_comment='[[:space:]]*#+[[:space:]]*' \
     -i <(echo '
         function trunc(s, w) {
             if (length(s) > w) { return substr(s, 1, w-3) "..."; }
             else               { return s; }
         }
         function varname(line) {
            n = split(line, parts, fs_assign);
            return parts[1];
         }
         function varvalue(line) {
            n = split(line, parts, fs_assign);
            return parts[2];
         }
         function comment(line) {
            if (line !~ /#/) { return ""; }
            n = split(line, parts, fs_comment)
            return parts[n]
         }
         function usage_header(line) {
            return gry line rst
         }
         function usage_variable(name, line)  {
            val=trunc(varvalue(line), 20)
            return "  " cyn name rst "=" gry val rst "\t" comment(line)
         }
         function usage_target(name, line) {
            return "  " blu name rst "\t" comment(line)
         }
         function usage_flag(line) {
            n = split(line, parts, fs_comment);
            return "  " pur parts[1] rst "\t" parts[2]
         }
         BEGIN { IGNORECASE=1; }
         $0 ~ exp_recipe  {next;}  # skip recipe lines
         $0 ~ exp_comment {next;}  # skip comment lines
     ') "$@" | uniq
}

# Get targets with descriptions from a Makefile.
# Parses targets by splitting ":" and "#".
# Format: TARGET <target> # <description>
_omb_completion_makefile_targets() {
     if test -n "$1"
     then _omb_completion_makefile_awk '
          BEGIN { FS=fs_target; }
          $0 ~ exp_target {printf "TARGET %s # %s\n", $1, $3;}
          ' "$1" 2>/dev/null
     fi
}

# Get variables with descriptions from a Makefile.
# Parses targets by splitting "=" and "#".
# Format: VAR <var>=<value> # <description>
_omb_completion_makefile_vars() {
     if test -n "$1"
     then _omb_completion_makefile_awk '
          $0 ~ exp_assign {printf "VAR %s = %s # %s\n", varname($0), varvalue($0), comment($0); }
          ' "$1" 2>/dev/null
     fi
}

# Get make flags/options with descriptions. Format:
# FLAG -<flag> --<long-flag> # <description>
# OPT -<option> <arg> --<long-option> # <description>
_omb_completion_makefile_flags() {
     echo "\
FLAG -h --help # Show extended usage info and exit.
FLAG -B --always-make # Unconditionally make all targets.
FLAG -n --dry-run # Don't actually run any recipe; just print them.
OPT -C DIR --directory=DIR # Change to DIR before doing anything.
OPT -f FILE --file=FILE # Read FILE as a makefile.
OPT -E STRING --eval=STRING # Evaluate STRING as a makefile statement.
"
}

# Get targets, variables, and make flags with descriptions from all Makefiles
# and included files. The return format is:
#
#   ---- <source/section> ----
#   TARGET <target> # <description>
#   VAR <var> = <value> # <description>
#   FLAG -<flag> --<long-flag> # <description>
#   OPT  -<option> <arg> --<long-option> # <description>
#
_omb_completion_makefile_comp_details() {
     shopt -u nullglob
     shopt -s nocaseglob

     local makefiles="*makefile"
     makefiles="*makefile $(_omb_completion_makefile_find_includes $makefiles)"

     for mf in $makefiles
     do
          echo "---- $mf ----"
          _omb_completion_makefile_targets "$mf"
          _omb_completion_makefile_vars "$mf"
     done
     echo "---- Make Options ----"
     _omb_completion_makefile_flags
}

# Get flat list of completions
_omb_completion_makefile_comp_list() {
     _omb_completion_makefile_comp_details |
     _omb_completion_makefile_awk '
     $1 == TARGET { print $2;}      # print only target names
     $1 == VAR    { print $2 "=";}  # print only variable names
     $1 == FLAG   { print $2, $3;}  # print only flag names
     $1 == OPT    { print $2, $4;}  # print only flag names
     '
}

# Get colored usage table for matching targets, vars, and flags.
# The return format is:
# ---- <section> ----
# <target>                        <desc>
# <var>=<value...>                <desc>
# -<flag> [<arg>] -<long-flag>    <desc>
#
# The output is formmated with the 'column' command as table.
_omb_completion_makefile_comp_usage() {
     _omb_completion_makefile_comp_details |
     _omb_completion_makefile_awk '
     $0 ~ exp_header            { print usage_header($0); }
     $1 == TARGET && $2 ~ query { $1=""; print usage_target($2, $0) }
     $1 == VAR    && $2 ~ query { $1=""; print usage_variable($2, $0) }
     $1 == FLAG   && $2 ~ query { $1=""; print usage_flag($0) }
     $1 == OPT    && $2 ~ query { $1=""; print usage_flag($0) }
     ' | column -t -s $'\t'
}

_omb_completion_makefile_reset() {
     _omb_completion_makefile_tab_presses=0
     _omb_completion_makefile_last_reply=""
     _omb_completion_makefile_last_queried_at=""
}

_omb_completion_makefile_tab_presses=0
_omb_completion_makefile_last_reply=""
_omb_completion_makefile_last_queried_at=""
_omb_completion_makefile_debug=""  # set to non-empty to enable debug output

# Main completion function for 'make' command.
# See top of file: completions/makefile.completion.sh for usage and description.
_omb_completion_makefile() {
     # Get all Makefile targets with descriptions
     local targets="$(_omb_completion_makefile_comp_list)"
     local usage="$(_omb_completion_makefile_comp_usage)"

     # clear old values if too much time has passed
     local now="$(command date +%s)"
     local t_last="${_omb_completion_makefile_last_queried_at:-0}"
     if (( now - t_last > 10 ))
     then _omb_completion_makefile_reset
     fi

     # get config, query, and prev. values
     local debug="$_omb_completion_makefile_debug"
     local query="${COMP_WORDS[COMP_CWORD]}"
     local presses=$_omb_completion_makefile_tab_presses
     local prev_reply="$_omb_completion_makefile_last_reply"

     # build new completion reply
     # cannot use 'compgen' with case-insensitive matching, so use grep
     COMPREPLY=($(echo "$targets" | command grep -iE "^$query" ))
     local reply="${COMPREPLY[*]}"
     local num_matches=${#COMPREPLY[@]}

     # Track repeated Tab presses on same input
     if test "$reply" = "$prev_reply"
     then presses=$((presses + 1))
     else presses=1
     fi

     # Update last queried values
     _omb_completion_makefile_tab_presses="$presses"
     _omb_completion_makefile_last_reply="$reply"
     _omb_completion_makefile_last_queried_at="$(command date +%s)"

     local ticks=("░" "▒" "▓" "▒")  # 4 frames
     local tick="${ticks[$((presses % 4))]}"
     # The repeat rotator indicates repeated tab presses without changed input.
     # It will appear behind the previous line:
     #
     #   user@host dirname ±|main ✗|→ make test-░
     #
     # The pattern should mimic a prompt cursor waiting for user action.
     if test "$presses" -lt 2
     then tick=""  # no rotator for 1st press
     fi

     if test -n "$debug"
     then _omb_util_print "$_omb_term_gray
          # Status:   query='$query', tabs=$presses, matches=$num_matches
          # State:    '$current_state'
          # Previous: '$prev_reply'
          # Current:  '$reply'
          # Flags:    '$( echo "$flags"   | tr '\n' ' ' )'
          # Targets:  '$( echo "$targets" | tr '\n' ' ' )'
          # Timing:   now=$now, last_queried_at=${t_last}s, dt_last=${dt_last}s
          # ----------------------------------------
          # Bash COMP Variables:
          # COMP_WORDS: '${COMP_WORDS[*]}'
          # COMP_CWORD: '${COMP_CWORD}'
          # COMP_LINE:  '${COMP_LINE}'
          # COMP_POINT: '${COMP_POINT}'
          # ----------------------------------------
          $_omb_term_reset
          " >&2
          # best-effort-restore command line input if altered by debug output
          if test "$num_matches" -eq 0
          then echo -n "$COMP_LINE" >&2
          fi
     fi

     case $num_matches in
     (0)  unset COMPREPLY;
          return ;;  # no match
     (1)  ;;  # single match: complete silently
     (*)
          # multiple matches, show usage or continue completion based on tab presses
          case $presses in
          (0)  ;; # this should not happen, treat as 1st tab press
          (1)  ;; # 1st tab press: no descriptions, just completions
          (*)
               # 2nd+ tab: show descriptions and indicate tab presses on previous line
               echo -e "$dark$tick$rst"
               echo -e "$usage" | command column -t -s $'\t'
               # echo -ne "$msg"
               ;;
          esac >&2
     esac
}

complete -F _omb_completion_makefile make
