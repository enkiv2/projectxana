import trans;
import enfilade;
import util;
import node;
import doc;
import enfs;

class XTP {
static synchronized char[] get(Enfs n, Enfilade d) {
	return (n.get(d)).stringOf();
}

static synchronized char[] get(Enfs n, XuSpan d) {
	if (d.start != d.end) {
		char[] temp;
		foreach (Enfilade e; d.start >> d.end) {
			temp~=e.stringOf();
			temp~=get(n, e);
		}
		return temp;
	}
	XuDoc s=n.get(d.start);
	s.doc.doc=s.doc.doc[d.vstart .. d.vend];
	foreach (XuLink l; s.links) {
		bool tooBig=0;
		if (l.forward.start==d.start) {
			if (l.forward.vstart < d.vstart) {
				if (l.forward.end==d.start && l.forward.vend < d.vend) {
					tooBig=1;
				} else {
					l.forward.vstart=0;
					l.forward.vend-=d.vstart;
				}
			}
			if (l.forward.vstart >= d.vstart) {
				l.forward.vstart -= d.vstart;
				if (l.forward.end == d.start) {
					if (l.forward.vend > d.vend) {
						l.forward.vend=d.vend;
					}
					l.forward.vend-=d.vstart;
				}
			}
				
		}
		if (l.back.start==d.start) {
			if (l.back.vstart < d.vstart) {
				if (l.back.end==d.start && l.back.vend < d.vend) {
					tooBig=1;
				} else {
					tooBig=0;
					l.back.vstart=0;
					l.back.vend-=d.vstart;
				}
			} else if (l.back.vstart >= d.vstart) {
				l.back.vstart -= d.vstart;
				if (l.back.end == d.start) {
					if (l.back.vend > d.vend) {
						l.back.vend=d.vend;
					}
					l.back.vend-=d.vstart;
				}
			}
		}
		if (tooBig) {
			l=newNull!(XuLink)(l);
		}
	}
	foreach (XuClude l; s.cludes) {
		bool tooBig=0;
		if (l.back.start == d.start) {
			if (l.back.vstart < d.vstart) {
				if (l.back.end==d.start && l.back.vend < d.vend) {
					tooBig=1;
				} else {
					tooBig=0;
					l.back.vstart=0;
					l.back.vend-=d.vstart;
				}
			} else if (l.back.vstart >= d.vstart) {
				l.back.vstart-=d.vstart;
				if (l.back.end == d.start) {
					if (l.back.vend > d.vend) {
						l.back.vend=d.vend;
					}
					l.back.vend-=d.vstart;
				}
			}
		}
		if (l.forward == d.start) {
			if (l.vforward > d.vend) {
				if (tooBig) {
					l=newNull!(XuClude)(l);
				}
			if (l.vforward >= d.vstart) {
				l.vforward -= d.vstart;
			}
		}
	}
	}
	return d.start.stringOf()~s.stringOf();
}
}
