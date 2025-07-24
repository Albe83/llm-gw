#!/bin/sh
set -e

# Print current user info
echo "[ENTRYPOINT] Running as user: $(id -un) (UID: $(id -u), GID: $(id -g))"

# Base command
CMD="/usr/local/bin/litellm"

echo "[ENTRYPOINT] Preparing command..."

# Add --config option if LITELLM_CONFIG is set and valid
if [ -n "$LITELLM_CONFIG" ] && [ -f "$LITELLM_CONFIG" ] && [ -s "$LITELLM_CONFIG" ]; then
    echo "[ENTRYPOINT] Using config: $LITELLM_CONFIG"
    CMD="$CMD --config \"$LITELLM_CONFIG\""
else
    echo "[ENTRYPOINT] No valid config file found or LITELLM_CONFIG not set."
fi

# Future variables logic
# Example:
# if [ -n "$SOME_OTHER_VAR" ]; then
#     echo "[ENTRYPOINT] Adding option for SOME_OTHER_VAR: $SOME_OTHER_VAR"
#     CMD="$CMD --other-option \"$SOME_OTHER_VAR\""
# fi

# Build final command
FINAL_CMD="$CMD \"$@\""

# Show the final command (for debugging)
echo "[ENTRYPOINT] Final command: $FINAL_CMD"

# Execute the command
exec sh -c "$FINAL_CMD"
