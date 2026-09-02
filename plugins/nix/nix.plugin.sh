#! bash oh-my-bash.module

function _nix_indicator_update_prompt() {
    if [[ -n "$IN_NIX_SHELL" ]]; then
        local original_ps1="$PS1" # Stores a local backup of PS1 to recheck.
        # Try \h (hostname) first
        PS1="${PS1/\\h/nix-shell}"
        # If unchanged, fallback to \u (username)
        if [[ "$PS1" == "$original_ps1" ]]; then
            PS1="${PS1/\\u/nix-shell}"
        fi
    fi
}

# Append  to PROMPT_COMMAND 
if [[ -z "$PROMPT_COMMAND" ]]; then # Cheking if PROMPT_COMMAND variable exists.
    PROMPT_COMMAND="_nix_indicator_update_prompt"
elif [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" =~ "declare -a" ]]; then # Cheking existing PROMPT_COMMAND if it is a string.
    PROMPT_COMMAND+=(_nix_indicator_update_prompt)
else
    PROMPT_COMMAND="${PROMPT_COMMAND}; _nix_indicator_update_prompt"
fi