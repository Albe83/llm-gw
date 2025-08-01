#!/bin/sh
set -e

# Print current user info
echo "[ENTRYPOINT] Running as user: $(id -un) (UID: $(id -u), GID: $(id -g))"

# Base command
CMD="/usr/local/bin/litellm"

echo "[ENTRYPOINT] Preparing command..."

# Build up the command using positional parameters to avoid quoting issues
if [ -n "$LITELLM_CONFIG" ] && [ -f "$LITELLM_CONFIG" ] && [ -s "$LITELLM_CONFIG" ]; then
    echo "[ENTRYPOINT] Using config: $LITELLM_CONFIG"
    set -- "$CMD" --config "$LITELLM_CONFIG" "$@"
else
    echo "[ENTRYPOINT] No valid config file found or LITELLM_CONFIG not set."
    set -- "$CMD" "$@"
fi

# Future variables logic
# Example:
# if [ -n "$SOME_OTHER_VAR" ]; then
#     echo "[ENTRYPOINT] Adding option for SOME_OTHER_VAR: $SOME_OTHER_VAR"
#     set -- "$1" --other-option "$SOME_OTHER_VAR" "${@:2}"
# fi

# Show the final command (for debugging)
printf '[ENTRYPOINT] Final command:'
for arg in "$@"; do
    printf ' %s' "$arg"
done
printf '\n'

# Execute the command
exec "$@"
