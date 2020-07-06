BEGIN {
	FS=","
}
NR == 1 {
	_x=1
	_arraylen=0
	while ( _x<=NF ) {
		gsub(/[ \[\]]+/,"",$_x) # Delete all [, ], [:space:]
		if ( _x == 2 ) {
            # Date - ignore. We receive $date from user in correct format
		} else if ( _x > 2 ) {
			tags[_arraylen++]=$_x
		}
		_x=_x+1
	}
}

END {
    print "<item>"
        print "<title>"heading"</title>"
        print "<link>https://soptik.tech/articles/"address"</link>"
        print "<guid>https://soptik.tech/articles/"address"</guid>"
        print "<description>"summary"</description>"
        print "<pubDate>"date"</pubDate>"
        for ( tag in tags ) {
            print "<category>"tags[tag]"</category>"
        }
    print "</item>"
}
