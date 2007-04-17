/+	trans
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
import enfilade;
import std.stdint;
import std.string;

struct XuSpan {
	Enfilade start;
	Enfilade end;
	uint64_t vstart;
	uint64_t vend;
	
	hash_t toHash() {
		int hash;
		char[] x=start.stringOf()~"c"~toString(vstart);
		foreach (char c; x) {
			hash=hash*7+c;
		}
		x=end.stringOf()~"c"~toString(vend);
		foreach (char c; x) {
			hash=hash*3-c;
		}
		return hash;
			
	}
	char[] stringOf() {
		char[] temp=start.stringOf()~"c"~toString(vstart);
		temp~="-";	// Separator (designates span)
		temp~=end.stringOf()~"c"~toString(vstart);
		return temp;
	}
	int opEquals(XuSpan s) {
		return (s.toHash()==this.toHash());
	}
	int opCmp(XuSpan s) {
		if( s.start==this.start) {
			if( s.end==this.end) {
				if( s.vstart==this.vstart) {
					return this.vend - s.vend;
				}
				return this.vstart-s.vstart;
			}
			return (this.end > s.end);
		}
		return (this.start > s.start);
	}
}

struct XuLink {
	XuSpan back;
	XuSpan forward;
	XuSpan threespan;

	hash_t toHash() {
		return (back > forward) - (back < threespan);
	}
	char[] stringOf() {
		return "P"~back.stringOf()~"~"~forward.stringOf()~"~"~threespan.stringOf();
	}
	int opEquals(XuLink s) {
		return (s.back==this.back) && (s.forward==this.forward) && (this.threespan==s.threespan);
	}
	int opCmp(XuLink s) {
		if (this.back==s.back) {
			if (this.forward==s.forward) {
				return (this.threespan>s.threespan);
			}
			return (this.forward>s.forward);
		}
		return (this.back>s.back);
	}
}

struct XuClude {
	XuSpan back;
	XuSpan threespan;
	Enfilade forward;
	uint64_t vforward;

	hash_t toHash() {
		return ((back > threespan) - (forward < threespan.start) + vforward);
	}
	int opEquals (XuClude s) {
		return ((s.back==this.back) && (s.forward==this.forward) && (this.threespan==s.threespan) && (s.vforward == this.vforward));
	}
	int opCmp(XuClude s) {
		if (this.back==s.back) {
			if (this.forward==s.forward) {
				if (this.threespan==s.threespan) {
					return (this.vforward > s.vforward);
				}
				return (this.threespan > s.threespan);
			}
			return (this.forward > s.forward);
		}
		return (this.back > s.back);
	}
	char[] stringOf() {
		return "C"~back.stringOf()~"~"~forward.stringOf()~"c"~toString(vforward)~"~"~threespan.stringOf();
	}
}
