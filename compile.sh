#!/bin/bash

# shellcheck disable=SC2013


# Compile folder. Convert markdown into HTML.

# Synopsis:
# compile.sh <source directory> [outputDirectory] [--no-tags]
#
# Where source directory contains files to be converted.
#
# Exit codes:
# 0 => Ok
# 99 => Configuration error
# (other) => Error while generating. Verify correct *md files structure.


# Exit on any error
set -eu
# Extended globbing operators
shopt -s extglob
# Create subshell and move to the current script location, so we can use
# relative paths. Things tend to break otherwise.
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
(
cd "$SCRIPTPATH"

do_generate_tags=true
source_directory="."
output_directory="outputDirectory"




#┌────────────┐
#│ INITIALIZE │
#└────────────┘
# This gets incremented as we process markdown files
total_number_of_words=0
start_time=$(date +%s.%N)



#┌─────────────┐
#│  P A R S E  │
#└─────────────┘

# Parse arguments
if [ $# -lt 1 ]; then
	>&2 echo "Usage: compile.sh <source directory> [output directory] [--no-tags]"
	exit 99
fi
source_directory="$1"
if [[ "$*" == *"--no-tags"* ]]; then
	do_generate_tags=false
fi
if [ $# -ge 2 ] && [ "$2" != "--no-tags" ]; then
	output_directory="$2"
fi

#┌─────────────────┐
#│    S T A R T    │
#└─────────────────┘

# Check for invalid file names
for markdown_filename in "$source_directory"/*.md; do
	if [[ "$markdown_filename" =~ "$source_directory"\/tail.*\.md || "$markdown_filename" =~ "$source_directory"\/head.*\.md ]]
	then
		>&2 echo "Forbidden filename in input directory: $markdown_filename. Filenames 'tail*.md' and 'head*.md' are forbidden."
		exit 99
	fi
done

# Prepare output directory
mkdir -p "$output_directory/html/css"
mkdir -p "$output_directory/html/js"

# Copy default index, head, tail, css, js.
cp "resources/"{"head","tail"}*.html "$output_directory"
cp "resources/"*.css "$output_directory/html/css"
cp "resources/"*.js "$output_directory/html/js"
cp "resources/tags.html" "$output_directory/tags.html"

# Copy user-provided head, tail, html, css and js - if any
cp {"$source_directory/head"*.html,"$source_directory/tail"*.html} "$output_directory" 2>/dev/null || true
cp "$source_directory/"*.css "$output_directory/html/css" 2>/dev/null || true
cp "$source_directory/"*.js "$output_directory/html/js" 2>/dev/null || true
cp "$source_directory/"*.html "$output_directory/html" 2>/dev/null || true
cp "$source_directory/tags.html" "$output_directory/tags.html" 2>/dev/null || true
# Prepare index file
cat "$output_directory/head.html" > "$output_directory/html/index.html"
cat "$output_directory/head.index.html" >> "$output_directory/html/index.html"

# Remove old tags.js if any
rm -f "$output_directory/html/js/tags.js" 2>/dev/null || true

# Prepare list of *md files provided by user that will be processed.
# We need them in reversed order
tmp_all_filenames_reversed=$(mktemp)
ls "$source_directory/"*.md -r > "$tmp_all_filenames_reversed";

# Create list of files for fast navigation
tmp_result_filenames=$(mktemp)
for filename in $(cat "$tmp_all_filenames_reversed"); do
	newname_without_extension=$(head -1 < "$filename" | cut -d"," -f1 | tr -d "\[ \]")
	echo "$newname_without_extension" >> "$tmp_result_filenames"
done

# Generate html files out of user md files.
# While doing this, write the files into index file AND tags file, if any.
# This loop basically does everything.
counter=1
for filename in $(cat "$tmp_all_filenames_reversed"); do
	# Get basic info about file
	newname_without_extension=$(head -1 < "$filename" | cut -d"," -f1 | tr -d "\[ \]")
	number_of_words=$(wc -w "$filename" | cut -d" " -f1)
	heading=$(sed -n 2p "$filename")
	summary=$(sed -n 3p "$filename")
	total_number_of_words=$((number_of_words+total_number_of_words))

	# Generate .html file from it
	if [[ $counter -gt 1 ]]; then
		next_filename=$(sed -n $((counter-1))p "$tmp_result_filenames")
	else
		next_filename=""
	fi
	previous_filename=$(sed -n $((counter+1))p "$tmp_result_filenames")
	cat "$output_directory/head.html" > "$output_directory/html/$newname_without_extension.html"
	gawk -f convert-to-html.awk -v previous_filename="$previous_filename.html" -v next_filename="$next_filename.html" -- "$filename" >> "$output_directory/html/$newname_without_extension.html"
	cat "$output_directory/tail.html" >> "$output_directory/html/$newname_without_extension.html"
	# And change .html file <title>
	sed -i 's/<title>.*<\/title>/<title>'"$heading"'<\/title>/' "$output_directory/html/$newname_without_extension.html"

	# If it doesn't contain --no-index, add to to general+tags index
	if [[ "$filename" = *"--no-index"* ]];
	then
		echo "Didn't index file $newname_without_extension.html"
	else
		# Add it into index
		gawk -f convert-to-index-entry.awk -v number_of_words="$number_of_words" -v heading="$heading" -v summary="$summary" -v address="$newname_without_extension.html" -- "$filename" >> "$output_directory/html/index.html"

		# Add all its tags into tags temp file
		if [[ "$do_generate_tags" == "true" ]]; then
			gawk -f extract-tags.awk -v filename="$newname_without_extension.html" -v heading="$heading" -v description="$summary" -v wordcount="$number_of_words"  -- "$filename" >> "$output_directory/html/js/tags.js"
		fi
	fi

	counter=$((counter+1))
done

# Finish index file
cat "$output_directory/tail.index.html" >> "$output_directory/html/index.html"
cat "$output_directory/tail.html" >> "$output_directory/html/index.html"
# Index title will be the same as <h1> content in index
h1_content_in_index=$(grep -e '<h1>.*</h1>' "$output_directory/html/index.html" | sed 's/<[^<]*>//g' | sed 's/^ *\t*//' | sed 's/ *\t*$//' | head -1)
sed -i 's/<title>.*<\/title>/<title>'"$h1_content_in_index"'<\/title>/' "$output_directory/html/index.html"

# Finish tags file
cat "$output_directory/head.tags.html" > "$output_directory/html/tags.html"
cat "$output_directory/tags.html" >> "$output_directory/html/tags.html"
cat "$output_directory/tail.html" >> "$output_directory/html/tags.html"

# Clean everything
rm -f "$tmp_result_filenames"
rm -f "$tmp_all_filenames_reversed"
rm -f "$output_directory/"{"head","tail","tags"}*.html

# Move everything out of inner /html directory
mv "$output_directory/html/"* "$output_directory/" 2>/dev/null || true
rm -rf "$output_directory/html"


#┌─────┐
#│ END │
#└─────┘
# Print nice statistics to stderr
COLOR_GREEN='\033[0;32m'
COLOR_CLEAR='\033[0m'
end_time=$(date +%s.%N)
process_time=$(bc <<< "$end_time - $start_time")
# We need to set LC_NUMERIC to american, so deciaml comma isn't used - bc uses decimal point
LC_NUMERIC="en_US.UTF-8" >&2 printf "Processed $COLOR_GREEN%'d$COLOR_CLEAR words in $COLOR_GREEN%0.2f$COLOR_CLEAR seconds\n" $total_number_of_words "$process_time"
)
