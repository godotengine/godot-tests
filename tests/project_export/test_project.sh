#!/usr/bin/env bash

# This script tests command-line editor functionality:
# - Exporting a project
# - Running a standalone script
#
# For exporting to work, a release export template for 64-bit Linux/X11
# must be installed.

set -euo pipefail
IFS=$'\n\t'

if [[ "$#" == 0 ]]; then
    echo "Usage: test_project.sh <path to Godot binary>"
	exit 1
fi

print_header() {
	printf "\n"
	printf -- "-%.0s" {0..72}
	printf "\n%s\n" "$1"
	printf -- "-%.0s" {0..72}
	printf "\n\n"
}

# The absolute path to the Godot binary
GODOT_BIN="$(readlink -e "$1")"

# The output filename relative to the project directory (without an extension)
OUTPUT_PATH="/tmp/project_export"

# Change to the directory where the script is located,
# so it can be run from any location
cd "$(dirname "${BASH_SOURCE[0]}")"

print_header "Testing command-line project exporting..."

# Export the project to test headless exporting functionality.
# This must be done *before* running the script, as assets need to be imported
# (exporting the project will automatically import assets).
"$GODOT_BIN" --export "Linux/X11" "$OUTPUT_PATH.x86_64"

if [[ ! -f "$OUTPUT_PATH.pck" ]]; then
    print_header "ERROR: No PCK file was created while exporting the project."
    exit 1
fi

if [[ "$(wc -c < "$OUTPUT_PATH.pck")" -lt 1000 ]]; then
    print_header "ERROR: The PCK file was created but its size is lower than 1 KB, which hints at a bug in the exporting process."
	exit 1
fi

print_header "Testing command-line script running..."

# Run a script to test script running functionality
"$GODOT_BIN" -s script.gd
