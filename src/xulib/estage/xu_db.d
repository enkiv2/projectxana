/+	xu_db
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
import std.stdint;
import enfilade;
import trans;
import doc;

typedef uint64_t[Enfilade][] xuloc;

struct xudb {
	uint loclength;
	xuloc lengths;
	XuLink[Enfilade][] transpointers;
	XuClude[Enfilade][] transclusions;
	Doc[Enfilade] docs;
	XuTitle titles;
}

