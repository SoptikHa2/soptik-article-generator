BEGIN {
	FS=","
}
NR == 1 {
	_x=1
	_arraylen=0
	while ( _x<=NF ) {
		gsub(/[ \[\]]+/,"",$_x) # Delete all [, ], [:space:]
		if ( _x == 2 ) {
			date=$_x
		} else if ( _x > 2 ) {
			tags[_arraylen++]=$_x
		}
		_x=_x+1
	}
}

END {
	print "<div class='index-entry'>"
		print "<h2 class='index-entry-heading'><a href='"address"'>"heading"</a></h2>"
		print "<div class='index-entry-tags'>"
			for ( tag in tags ) {
				print "<span class='index-entry-tag'>"
					print "<a href='tags.html?tag="tags[tag]"'>"tags[tag]"</a>"
				print "</span>"
			}
		print "</div>"
		print "<div class='index-entry-date'>"
			print date
		print "</div>"
		print "<div class='index-summary'>"
			print "<p class='index-entry-summary'>"summary"</h2>"
		print "</div>"
		print "<a class='index-click-more-label' href='"address"'>("number_of_words" words)</a>"
	print "</div>"
	print "<hr />"
}
