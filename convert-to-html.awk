BEGIN 	{
	print "<article>"
	FS=","
	is_inside_code_block=0
}

NR == 1 {
	# Tags
	print "<div class=\"tags\">"
	
	x=1
	arrayidx=0
	while ( x<=NF ) {
		sub(/[ \[\]]+/,"",$x)
		sub(/[ \]]+/,"",$x)
		if ( x == 1 ) { } # Filename, ignore
		else if ( x == 2 ) { # Date
			written_date=$x
		}else { # Tag
			tags[arrayidx++]=$x
		}
		x++
	}
	print "</div>"
}

NR == 2 {
# Heading
	print "<h1 class='article-heading'>"$0"</h1>"
	print "<div class='article-tags'>"
		for (tag in tags) {
			print "<div class='article-tag'><a href='tags.html?tag=" tags[tag] "'>" tags[tag] "</a></div>"
		}
	print "</div>"
	print "<p class='article-date'>Written on " written_date ".</p>"
}

NR > 2 {
	# Text content
	text=$0 # The final text to render
	enclose_in_p=1 # Should the final text be enclosed in <p>?

	# First of all, remove html tags. Maybe add whitelist later?
	sub("<", "< ", text)
	sub(">", " >", text)
	
	if ( text ~ /^[ ]*`{3,}[ ]*$/ ) { # Code block
		if ( is_inside_code_block == 0 ) {
			text= "<p><pre>" 
			is_inside_code_block = 1
		}else{
			text= "</pre></p>"
			is_inside_code_block = 0
		}
	}
	else	{
		if ( text ~ /^#[^#]/ ) { # Heading
			sub(/^# */,"",text)
			text= "<h2>" text "</h2>"
			enclose_in_p=0
		}
		else if ( text ~ /^##[^#]/ ) { # Subheading
			sub(/^## */,"",text)
			text= "<h3>" text "</h3>"
			enclose_in_p=0
		}

		if ( text ~ /\[[^\]]*\]\([^\)]*\)/ ) { # Link
			text=gensub(/\[([^\]]*)\]\(([^\)]*)\)/, "<a href=\"\\2\">\\1</a>", "g", text)
		}
		if ( text ~ /`[^`\n]+`/ ) { # Inline code
			text=gensub(/`([^\`]+)`/, "<code>\\1</code>", "g", text)
		}
		if ( text ~ /\*\*.*\*\*/ ) { # Bold text
			text=gensub(/\*\*([^(\*\*)]+)\*\*/, "<b>\\1</b>", "g", text)
		}
		if ( text ~ /\*.*\*/ ) { # Italics
			text=gensub(/\*([^\*]+)\*/, "<i>\\1</i>", "g", text)
		}
		
		if ( text ~ /^[ ]*-{3,}[ ]*$/ ) { # Line
			text="<hr />"
			enclose_in_p=0
		}
		if ( text ~ /^[ ]*>/ ) { # Quote
			text= "<q>" text "</q>"
		}
#		if ( text ~ /^[ ]*$/ ) { # Empty line LOOKS BAD
#			text="<br />"
#			enclose_in_p=0
#		}
	}

	if ( enclose_in_p == 1 && is_inside_code_block == 0 ) {
		print "<p>" text "</p>"
	} else {
		print text
	}
}

END	{
	print "<div class='bottom-nav'>"
	if (previous_filename ~ ".+\\.html$") {
		print "<a class='a-prev' href='" previous_filename "'>Previous</a>"
	}
	print "<a class='a-home' href='index.html'>Home</a>"
	if (next_filename ~ ".+\\.html$") {
		print "<a class='a-next' href='" next_filename "'>Next</a>"
	}
	print "</article>"
}
