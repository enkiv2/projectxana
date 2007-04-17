import interrupt;
import node;
import enfilade;
import trans;
import cell;
import doc;
import std.string;
import enfs;

void register_driver(Enfs n, uint irq, Enfilade handler, Enfilade deviceOut) {
	set_idt(n, handler, irq);
	XuDoc doc;
	doc.doc.doc="__OUT";
	XuDoc doc2;
	doc2.doc.doc=toString(irq);
	doc2.links[1].back.start=deviceOut;
	doc2.links[1].back.end=deviceOut;
	doc2.links[1].back.vstart=0;
	doc2.links[1].back.vend=5;
	n.add(doc2, deviceOut~1);
	doc.links[1].forward.start=deviceOut~1;
	doc.links[1].forward.end=deviceOut~1;
	doc.links[1].forward.vstart=0;
	doc.links[1].forward.vend=50;
	n.add(doc, deviceOut);
}

