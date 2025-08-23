#!/usr/bin/env bash

set -o pipefail

# Resolve files to absolute paths
CONFIG_ABS_PATH="$(readlink -f "${INPUT_CONFIG_FILE}")"
CREDS_ABS_PATH="$(readlink -f "${INPUT_CREDS_FILE}")"

WORKING_DIR="$(dirname "${CONFIG_ABS_PATH}")"
cd "$WORKING_DIR" || exit

ARGS=(
	"$@"
	--config "$CONFIG_ABS_PATH"
)

# `check` subcommand doesn't require credentials
if [ "$1" != "check" ]; then
	ARGS+=(--creds "$CREDS_ABS_PATH")
fi

IFS=
OUTPUT="$(dnscontrol "${ARGS[@]}")"
EXIT_CODE="$?"

echo "$OUTPUT"

# Set output
# https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#multiline-strings
DELIMITER="DNSCONTROL-$RANDOM"

{
	echo "output<<$DELIMITER"
	echo "$OUTPUT"
	echo "$DELIMITER"
} >>"$GITHUB_OUTPUT" | tee -a $GITHUB_STEP_SUMMARY

exit $EXIT_CODE
