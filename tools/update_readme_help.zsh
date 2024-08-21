#!/bin/zsh

file="README.md"
helpfile="${0:A:h}/../tests/snapshot.txt"

if [[ "$1" == "-u" ]]; then
  shift
  . "${0:A:h}/../tests/update_snapshot.zsh"
fi

tmpfile=$(mktemp)
help="$(cat $helpfile)"

echo "Updating help in $file"

# Write content up to and including the <!--HELP_OUTPUT_START--> tag
sed -n '/<!--HELP_OUTPUT_START-->/q;p' "$file" >> "$tmpfile"
echo "<!--HELP_OUTPUT_START-->" >> "$tmpfile"

# Append the content of the $help variable
echo "\`\`\`sh\n$help\n\`\`\`" >> "$tmpfile"

# Append content from the <!--HELP_OUTPUT_END--> tag onwards
sed -n '/<!--HELP_OUTPUT_END-->/,$p' "$file" >> "$tmpfile"

mv "$tmpfile" "$file"

echo "Help updated"
