import enfilade;
import doc;
import trans;
import node;
import cell_core;
import cell_nd;
import enfs;

version (fe) {
	import cell_UI;
}

int delegate(Enfs, Enfilade, XuLink[], XuClude[])[char[]] api;
void init_api () {
	cell_core.init_api();
	foreach (char[] c, x; cell_core.api) {
		api[c]=x;
	}
	version (fe) {
		cell_UI.init_api();
		foreach (char[] c, x; cell_UI.api) {
			api[c]=x;
		}
	}
	cell_nd.init_api();
	foreach (char[] c, x; cell_nd.api) {
		api[c]=x;
	}
}
