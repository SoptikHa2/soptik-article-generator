BEGIN {
	inside_to_be_highlighted_code_block = 0
	srand()
}
# When we reach end of highlighted code block, clear inside_to_be_highlighted_code_block flag and
# print highlighted string
/^<\/pre>$/ {
	inside_to_be_highlighted_code_block=0
	# Print highlighted string
	{
		# First of all, generate random filename
		code_filename="/tmp/soptik-article-generator.source-code-to-highlight." rand()
		# And write the code into it
		print source_code_to_highlight > code_filename
		close(code_filename)
		# Now call python script to try to highlight it
		cmd="python3 " highlight_python_scriptfile " '" code_filename "' '" langname "'"
		while ( ( cmd | getline result ) > 0 ) {
			print result
		}
		close(cmd)

		source_code_to_highlight = ""
		# Remove the random filename
		system("rm -- '" code_filename "'")
	}
}
# If we are processing normal text, print it
inside_to_be_highlighted_code_block == 0 {
	print $0
}
# If we are inside highlighted block, add it into source code to highlight
inside_to_be_highlighted_code_block == 1 {
	source_code_to_highlight = source_code_to_highlight $0 "\n"
}
# Wait until we see <pre> with langname, which means we should colorcode the following segment
/^<pre langname='(.+)'>$/ {
	inside_to_be_highlighted_code_block=1
	langname=gensub(/^<pre langname='(.+)'>$/, "\\1", "g", $0)
}
