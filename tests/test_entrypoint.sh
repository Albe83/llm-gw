#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG="$ROOT_DIR/litellm_config.yaml"
ENTRYPOINT="$ROOT_DIR/entrypoint.sh"

DUMMY="/usr/local/bin/litellm"
BACKUP=""
if [ -f "$DUMMY" ]; then
    BACKUP="$DUMMY.bak"
    mv "$DUMMY" "$BACKUP"
fi
cat <<'EOS' > "$DUMMY"
#!/bin/sh
echo "dummy litellm $@"
EOS
chmod +x "$DUMMY"

cleanup() {
    rm -f "$DUMMY"
    if [ -n "$BACKUP" ]; then
        mv "$BACKUP" "$DUMMY"
    fi
}
trap cleanup EXIT

OUTPUT=$(LITELLM_CONFIG="$CONFIG" sh "$ENTRYPOINT" --prompt "hello world" 2>&1 || true)

echo "$OUTPUT" | grep -Fq "[ENTRYPOINT] Using config: $CONFIG"
echo "$OUTPUT" | grep -Fq -- "--config \"$CONFIG\""
echo "$OUTPUT" | grep -Fq -- '"--prompt hello world"'
