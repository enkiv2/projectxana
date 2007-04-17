import enfilade;
import doc;
import trans;
import node;
import cell_lib;
import enfs;

class EPL {
static synchronized int interpCell(Enfs n, Enfilade e) {
	cell_lib.init_api();
	XuDoc doc=n.get(e);
	if (doc.doc.doc in cell_lib.api) {
		return cell_lib.api[doc.doc.doc](n, e, doc.links, doc.cludes);
	} 
	return -1;
}

static synchronized Enfilade interp3Span(Enfs n, XuLink l) {
	// To Do
	Enfilade x;
	return x;
}

static synchronized Enfilade interp3Span(Enfs n, XuClude c) {
	// To Do
	Enfilade x;
	return x;
}
}
