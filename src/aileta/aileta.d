module aileta;

import kernel_assert;
import std.stdio;
import Stdout;
import Stdin;
import node;
import enfilade;
import trans;
import doc;
import enfs;

Enfs filesystem;
Enfilade current;

void draw_z2() {
	Stdout.Stdout.clearScreen();
	Stdout.Stdout.gotoPosition(80/2, 25/2);
	int x=80/2;
	int y=25/2;
	XuDoc d=filesystem.get(current);
	putc(d.title[0]);
	Stdout.Stdout.gotoPosition(x+2, y+2);
	puts(d.title);
	XuDoc d2=filesystem.get(d.cludes[0].forward);
	for (int i=1; i<40; i++) {
		Stdout.Stdout.gotoPosition(x+i, y);
		putc(d2.title[0]);
		d2=filesystem.get(d2.cludes[0].forward);
	}
	d2=filesystem.get(d.links[0].forward.start);
	for (int i=1; i<12; i++) {
		Stdout.Stdout.gotoPosition(x, y+i);
		putc(d2.title[0]);
		d2=filesystem.get(d2.links[0].forward.start);
	}
	return '\0';
}

char process_z2_key() {
	char k=Stdin.KB_read();
	while (k=='\0' && Stdin.KB_KEYMAP==0) {
		k=Stdin.KB_read();
		asm{hlt;}
	}
	if (KB_KEYMAP&KB_LEFT) {
		current=filesystem.get(current).cludes[0].forward;
	}
	if (KB_KEYMAP&KB_DOWN) {
		current=filesystem.get(current).links[0].forward.start;
	}
	if (KB_KEYMAP&KB_RIGHT) {
		current=filesystem.get(current).cludes[0].back.start;
	}
	if (KB_KEYMAP&KB_UP) {
		current=filesystem.get(current).links[0].back.start;
	}
	if (k=='i') {
		putc('\b');
		Stdout.Stdout.gotoPosition((80/2)+2, (25/2)+2);
		XuDoc c=filesystem.get(current);
		c.title=std.stdio.getln();
		Stdout.Stdout.clearScreen();
		puts("Editing "~c.title~"\n");
		char[] t=std.stdio.getln();
		c.doc.doc="";
		while (t!="\27") {
			c.doc.doc~=t;
			t=std.stdio.getln();
		}
		filesystem.set(c, current);
	}
	return '\0';
}

void do_z2() {
	bool done=0;
	asm{hlt;}
	char k=Stdin.KB_read();
	while (!done) {
		draw_z2();
		k=process_z2_key();
		if (k=='Q') {
			done=1;
		}
	}
}

void init_node() { //kernel_assert.kernel_assert(89, "aileta.d", "init_node called");
	void[] x; //kernel_assert.kernel_assert(1, "aileta.d", "90");
	x.length=500;
	kernel_assert.kernel_assert(92, "aileta.d", "init_node past void[] x");
	filesystem.init(x);
//	kernel_assert.kernel_assert(94, "aileta.d", "init_node past filesystem.init()");
	filesystem.format();
	kernel_assert.kernel_assert(96, "aileta.d", "init_node past filesystem_format");
	filesystem.setup();
}
void init() {
	current~=1;
	do_z2();
}

