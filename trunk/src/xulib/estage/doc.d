/+	doc.d
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
import trans;
import enfilade;
import util;
import std.string;
import std.stdint;

typedef char[Enfilade][] XuTitle;

struct Doc {
	char[] doc;
	XuSpan threespan;
}

struct XuDoc {
	Doc doc;
	char[] title;
	XuLink[] links;
	XuClude[] cludes;
	XuSpan threespan;

	char[] stringOf () {
		char[] temp= threespan.stringOf()~"~"~title~"~";
		foreach (XuLink l; links) {
			if (!(isNull!(XuLink)(l))) {
				temp~=l.stringOf();
			}
		}
		temp~="~";
		foreach (XuClude c; this.cludes) {
			if (!(isNull!(XuClude)(c))) {
				temp~=c.stringOf();
			}
		}
		temp~="~l"~toString(doc.doc.length)~"~\n"~doc.doc;
		return temp;
	}
}

