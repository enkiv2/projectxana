import enfilade;
import doc;
import trans;
import node;
import util;
import cell;
import std.string;
import enfs;

int delegate(Enfs n, Enfilade, XuLink[], XuClude[])[char[]] api;

void init_api() {
	api["set"] = delegate(Enfs n, Enfilade e, XuLink[] links, XuClude[] cludes) {
		if (cludes.length==0) {
			return -1;
		}
		if (links.length==0) {
			return -1;
		}
		if (!(isNull!(XuSpan)(links[1].threespan))) {
			n.add(n.get(cludes[1].forward), EPL.interp3Span(n, links[1]));
		} else {
			n.add(n.get(cludes[1].forward), links[1].forward.start);
		}
		return 0;
	};
	api["chug"] =  delegate(Enfs n, Enfilade e, XuLink[] links, XuClude[] cludes) {
		if (links.length==0) {
			return -1;
		}
		XuDoc doc, doc2;
		doc=n.get(e);
		if (!(isNull!(XuSpan)(links[1].threespan))) {
			doc2=n.get(EPL.interp3Span(n, links[1]));
		} else {
			doc2=n.get(links[1].forward.start);
		}
		if(doc2.links.length==0) {
			return -1;
		}
		doc.links[1]=doc2.links[1];
		n.add(doc, e);
		return 0;
	};/+
	api["add"] =  delegate(XuNode n, Enfilade e, XuLink[] links, XuClude[] cludes) {
		if (links.length==0) {
			return -1;
		}
		if (cludes.length==0) {
			return -1;
		}
		XuLink ret;
		if (links.length==1) {
			ret=links[1];
		} else {
			ret=links[2];
		}
		if (!(isNull!(XuSpan)(ret.threespan))) {
			ret.forward.start=EPL.interp3Span(n, ret);
		}
		XuClude addend=cludes[1];
		if (!(isNull!(XuSpan)(addend.threespan))) {
			addend.forward=EPL.interp3Span(n, addend);
		}
		XuDoc doc=n.get(ret.forward.start);
		if (!(isNull!(XuSpan)(links[1].threespan))) {
			doc.doc=toString(toFloat(n.get(EPL.interp3Span(n, links[1])).doc)+toFloat(n.get(addend.forward).doc));
			n.add(doc, ret.forward.start);
		} else {
			doc.doc=toString(atof(n.get(links[1].forward.start).doc)+(atof(n.get(addend.forward).doc)));
			n.add(doc, ret.forward.start);
		}
		return 0;
	};+/
	
}
