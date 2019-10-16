# This generates JS code that will add current filename (.html)
# into dictionary, to all tags.
# Example:
# // For example this file abc.html has tags [ dog, cat ]
# if(typeof tags == "undefined") tags = [];
# if(!tags["dog"]) tags["dog"] = [];
# tags["dog"].push("abc.html");
# if(!tags["cat"]) tags["cat"] = [];
# tags["cat"].push("abc.html");
# // End of code
#
# It starts getting weird after few files, since most
# tags are reused, but whatever.
#
# I could probably write an utilty that will remove duplicate
# "if tag exists" checks, but it probably won't be done.

BEGIN {
	FS=","
	print "if(typeof tags == \"undefined\") tags = [];"
}

NR == 1 {
	# Tags
	x = 3
	while( x<=NF ) {
		sub(/[ \[\]]+/,"",$x)
		sub(/[ \]]+/,"",$x)
		print "if(!tags[\""$x"\"]) tags[\""$x"\"] = [];"
		print "tags[\""$x"\"].push({name: \""filename"\", heading: \""heading"\", description: \""description"\", wordcount: "wordcount"});"
		x++
	}
}

END {
	print "tag_keys_ordered = Object.keys(tags).sort(function(x, y) { return tags[x].length < tags[y].length ? -1 : 1;}); tag_keys_ordered.reverse();"
}
