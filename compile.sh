#!/bin/bash
# Compile folder. Convert markdown into HTML.

# Synopsis:
# compile.sh <source directory> [outputDirectory] [--no-tags]
#
# Where source directory contains files to be converted.
#
# Files with extension ".md" are converted into HTML and the
# new HTML file is placed into the "outputDirectory".
# Forbidden filenames are "{head.*,tail.*}.md"
#
# Files with extension "*.css" and "*.js" are simply
# copied into directory "outputDirectory/{css,js}".
#
# If you want to specify custom css theme, create "base.css" in source folder.
# You can use "@import url('base-light.css')" for default light theme (and 'base-dark' for default dark theme)
#
# Other files are copied into "outputDirectory".
#
# This by default creates index.html and adds navigation (prev/index/next)
# to all files. This can be overwritten by custom {head.html,tail.html,head.index.html,tail.index.html,base.css} in source directory.
# Files that are used to generate HTML ({head.html,tail.html,...}) won't be copied into "outputDirectory".
#
# By default tag index (with filtering) is created as well, this can be prevented by
# setting the --no-tags parameter.
#
# Markdown specification can be found in README file.
#
# EXIT CODES
# 0 => Ok
# 99 => Configuration error
# (other) => Error while generating. Verify correct *md files structure.


# Exit on any error
set -eu
# Extended globbing operators
shopt -s extglob

do_generate_tags=true
source_directory="."
output_directory="outputDirectory"






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

# Copy default index, head, tail, css.
cp "resources/"{"head","tail"}*.html "$output_directory"
cp "resources/"*.css "$output_directory/html/css"

# Copy user-provided head, tail, html, css and js - if any
cp {"$source_directory/head*.html","$source_directory/tail*.html"} "$output_directory" 2>/dev/null || true
cp "$source_directory/*.css" "$output_directory/html/css" 2>/dev/null || true
cp "$source_directory/*.js" "$output_directory/html/js" 2>/dev/null || true
cp "$source_directory/*.html" "$output_directory/html" 2>/dev/null || true

# Prepare index file
cat "$output_directory/head.html" > "$output_directory/html/index.html"
cat "$output_directory/head.index.html" >> "$output_directory/html/index.html"

# Create list of files for fast navigation
tmp_result_filenames=$(mktemp)
for filename in "$source_directory"/*.md; do
	newname_without_extension=$(head -1 < "$filename" | cut -d"," -f1 | tr -d "\[ \]")
	echo "$newname_without_extension" >> "$tmp_result_filenames"
	printf "\n" >> "$tmp_result_filenames"
done

# Generate html files out of user md files.
# While doing this, write the files into index file AND tags file, if any.
# This loop basically does everything.
counter=1
for filename in "$source_directory"/*.md; do
	# Get basic info about file
	newname_without_extension=$(head -1 < "$filename" | cut -d"," -f1 | tr -d "\[ \]")
	number_of_words=$(wc -w "$filename" | cut -d" " -f1)
	heading=$(sed -n 2p "$filename")
	summary=$(sed -n 3p "$filename")

	# Generate .html file from it
	if [[ $counter -gt 1 ]]; then
		previous_filename=$(sed -n $((counter-1))p "$tmp_result_filenames")
	else
		previous_filename=""
	fi
	next_filename=$(sed -n $((counter+1))p "$tmp_result_filenames")
	cat "$output_directory/head.html" > "$output_directory/html/$newname_without_extension.html"
	gawk -f convert-to-html.awk -v previous_filename="$previous_filename" -v next_filename="$next_filename" -- "$filename" >> "$output_directory/html/$newname_without_extension.html"
	cat "$output_directory/tail.html" >> "$output_directory/html/$newname_without_extension.html"
	# And change .html file <title>
	sed -i 's/<title>.*<\/title>/<title>'"$heading"'<\/title>/' "$output_directory/html/$newname_without_extension.html"

	# Add it into index
	gawk -f convert-to-index-entry.awk -v number_of_words="$number_of_words" -v heading="$heading" -v summary="$summary" -v address="$newname_without_extension.html" -- "$filename" >> "$output_directory/html/index.html"

	# TODO: Tags

	counter=$((counter+1))
done

# Finish index file
cat "$output_directory/tail.index.html" >> "$output_directory/html/index.html"
cat "$output_directory/tail.html" >> "$output_directory/html/index.html"
# Index title will be the same as <h1> content in index
h1_content_in_index=$(grep -e '<h1>.*</h1>' "$output_directory/html/index.html" | sed 's/<[^<]*>//g' | sed 's/^ *\t*//' | sed 's/ *\t*$//' | head -1)
sed -i 's/<title>.*<\/title>/<title>'"$h1_content_in_index"'<\/title>/' "$output_directory/html/index.html"

# Clean everything
rm -f "$tmp_result_filenames"
rm -f "$output_directory/"{"head","tail"}*.html
