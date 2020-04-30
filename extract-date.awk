BEGIN {
	FS=","
}
NR == 1 {
	_x=1
	while ( _x<=NF ) {
		gsub(/[ \[\]]+/,"",$_x) # Delete all [, ], [:space:]
        # Date
		if ( _x == 2 ) {
            print $_x
        }
        _x++
	}
}
