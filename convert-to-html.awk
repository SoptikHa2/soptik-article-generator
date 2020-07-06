BEGIN 	{
	print "<article>"
	FS=","
	is_inside_code_block=0

	syntax_highlighting__langname=""
}

NR == 1 {
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
}

NR == 2 {
# Heading
	print "<h1 class='article-heading'>"$0"</h1>"
	print "<div class='article-tags'>"
		for (tag in tags) {
			print "<div class='article-tag'><a href='tags.html?tag=" tags[tag] "'>" tags[tag] "</a></div>"
		}
	print "</div>"
	print "<p class='article-date'>Written on <time>" written_date "</time>.</p>"
}

NR > 2 {
	# Text content
	text=$0 # The final text to render
	enclose_in_p=1 # Should the final text be enclosed in <p>?
	
	if ( text ~ /^[ ]*`{3,}[A-Za-z]*[ ]*$/ ) { # Code block
		if ( is_inside_code_block == 0 ) {
			is_inside_code_block = 1
			match($0,/^[ ]*`{3,}([A-Za-z]*)[ ]*$/,__syntaxlangarray)
			syntax_highlighting__langname = __syntaxlangarray[1]
			text = ""
		} else {
			enclose_in_p=0
			text = "<pre langname='" syntax_highlighting__langname "'>\n" syntax_highlighting__contents "</pre>"
			is_inside_code_block = 0
			syntax_highlighting__contents = ""
		}
	}
	else if ( is_inside_code_block == 1 ) {
		# If inside code block, don't print or do anything,
		# just store text into buffer
		syntax_highlighting__contents = syntax_highlighting__contents text "\n"
		text = ""
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

		if ( text ~ /((\\\\)|[^\\]|^){[^}]*}\([^\)]*\)/ ) { # Image
			text=gensub(/{([^}]*)}\(([^\)]*)\)/, "<img src=\"\\2\" alt=\"\\1\" />", "g", text) 
		}
		if ( text ~ /((\\\\)|[^\\]|^)\[[^\]]*\]\([^\)]*\)/ ) { # Link
			text=gensub(/\[([^\]]*)\]\(([^\)]*)\)/, "<a href=\"\\2\">\\1</a>", "g", text)
		}
		if ( text ~ /((\\\\)|[^\\]|^)`[^`\n]+`/ ) { # Inline code
			text=gensub(/`([^\`]+)`/, "<code>\\1</code>", "g", text)
		}
		if ( text ~ /((\\\\)|[^\\]|^)\*{2}.*\*{2}/ ) { # Bold text
			text=gensub(/\*\*([^(\*\*)]+)\*\*/, "<b>\\1</b>", "g", text)
		}
		if ( text ~ /((\\\\)|[^\\]|^)\*.*\*/ ) { # Italics
			text=gensub(/\*([^\*]+)\*/, "<i>\\1</i>", "g", text)
		}
		if ( text ~ /((\\\\)|[^\\]|^)~~.*~~/ ) { # Strikethrough
			text=gensub(/~~([^\*]+)~~/, "<del>\\1</del>", "g", text)
		}
		
		if ( text ~ /^[ ]*-{3,}[ ]*$/ ) { # Line
			text="<hr />"
			enclose_in_p=0
		}
		if ( text ~ /^[ ]*>/ ) { # Quote
			text= "<q>" text "</q>"
		}
	}

	# Process escaped backslashes (\\ => \)
	text=gensub("\\\\", "\\", "g"more, text)

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
	print "<a class='a-home' href='index.html'>Index</a>"
	print "<a class='a-home' href='/'>Home</a>"
	if (next_filename ~ ".+\\.html$") {
		print "<a class='a-next' href='" next_filename "'>Next</a>"
	}
	print "</div>"
    print "<div class='bottom-nav'>"
    print "<a class='a-home' href='rss.xml'>RSS feed</a>"
    print "</div></article>"
}
