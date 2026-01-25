#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Output file (default)
out=${1:-dump-files.txt}

# Names to exclude (output file and this script)
script_name=$(basename -- "$0")
out_name=$(basename -- "$out")

# Start fresh
: > "$out"

# Find files under current directory only, skipping .terraform and listed files,
# plus the output file and the script itself. Produce NUL-separated paths.
find . \
  \( -name '.terraform' -o -name 'README.md' -o -name 'important-commands.txt' \
     -o -name '.terraform.lock.hcl' -o -name 'terraform.tfstate' \
     -o -name "$out_name" -o -name "$script_name" \) -prune -o \
  -type f -exec printf '%s\0' {} + |
while IFS= read -r -d '' file; do
  file_display=${file#./}
  printf '%s\n' "---- $file_display" >> "$out"
  cat -- "$file" >> "$out"
  printf '\n' >> "$out"
done
