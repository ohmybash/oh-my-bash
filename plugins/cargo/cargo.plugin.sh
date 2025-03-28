#! bash oh-my-bash.module
# @sjplanet 2025

# Set CARGO_HOME to default if not already set
: "${CARGO_HOME:=$HOME/.cargo}"

# Check if the directory exists
if [ -d "$CARGO_HOME" ]; then
    # Add $CARGO_HOME/bin to PATH if it's not already included
    case ":$PATH:" in
        *":$CARGO_HOME/bin:"*) ;;  # already in PATH, do nothing
        *) export PATH="$CARGO_HOME/bin${PATH:+:$PATH}" ;;
    esac
fi