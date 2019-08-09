#!/bin/bash
# Compile folder. Convert markdown into HTML.

# Synopsis:
# compile.sh <source directory> [outputDirectory] [--no-tags]
#
# Where source directory contains files to be converted.
#
# Files with extension ".md" are converted into HTML and the
# new HTML file is placed into the "outputDirectory".
#
# Files with extension "*.css" and "*.js" are simply
# copied into "outputDirectory/{css,js}".
#
# Other files are copied into "outputDirectory".
#
# This by default creates index.html and adds navigation (prev/index/next)
# to all files. This can be overwritten by custom {head.html,tail.html,index.html,tags.html,base.css} in source directory.
# Files that are used to generate HTML ({head.html,tail.html,base.css}) won't be copied into "outputDirectory".
#
# By default tag index (with filtering) is created as well, this can be prevented by
# setting the --no-tags parameter.
#
# Markdown specification can be found in README file.


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
	>&2 echo "Usage: compile.sh <source directory> [output directory] "
	exit 1
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

# Prepare output directory
mkdir -p "$output_directory"
mkdir -p "$output_directory/css"
mkdir -p "$output_directory/js"
cp {"head.html","tail.html","index.html"} "$output_directory/html"
cp "base.css" "$output_directory/css"
$do_generate_tags && cp "tags.html" "$output_directory/tags.html"

# Copy user-provided files
cp "$source_directory"/*.html "$output_directory" || true
cp "$source_directory"/*.css "$output_directory/css" || true
cp "$source_directory"/*.js "$output_directory/js" || true
cp "$source_directory/!(*@(.css|.html|.js))" "$output_directory" || true

# Index.html
tempfile_index_content=$(mktemp)
for filename in "$source_directory"/*.md; do
	newname=$(tr -d "\[ \]" <<< "$(head -1 "$filename")" | cut -d, -f1)
	number_of_words=$(wc -w "$filename" | cut -d" " -f1)
	echo "<p><a href=\"$newname.html\">$newname</a>, $number_of_words words</p>" >> "$tempfile_index_content"
done
tempfile_full_indexfile_content=$(mktemp)
sed "s/>>>>>ARTICLES_HERE<<<<</$(cat "$tempfile_index_content")/g" < "$source_directory/index.html" > "$tempfile_full_indexfile_content"
mv "$tempfile_full_indexfile_content" "$source_directory/index.html"
rm -f $"tempfile_full_indexfile_content"
rm -f $"tempfile_index_content"

# Process markdown
for filename in "$source_directory"/*.md; do
	newname=$(tr -d "\[ \]" <<< "$(head -1 "$filename")" | cut -d, -f1)
	cp "head.html" "$output_directory/$newname.html"
	gawk -f convert-to-html.awk -- "$filename" >> "$output_directory/$newname.html"
	cat "tail.html" >> "$output_directory/$newname.html"
done

# Generate tags
if [ $do_generate_tags ]; then
	rm -f "$output_directory/js/tags.js"
	for filename in "$source_directory"/*.md; do
		awk -f generate-tags.awk -- "$filename" >> "$output_directory/js/tags.js"
	done
fi

