/+	std.memory
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
module std.memory;

public import Memory;

private import gc;
//private import node;
/+private import Memory;
alias Memory.memcpy memcpy;
int memcmp (void* a, void* b, uint l) {
	Memory.memcmp!(void*)(a, b, l);
}
void memmove (void* a, void* b, uint l) {
	memcpy(a, b, l);
}

void memset (void* b, int m, uint l) {
	memcpy(b, &m, l);
}
+/
//public import memset;
void* calloc(int x) {
	return gc.gc.malloc(cast(uint)x);
}
//alias gc.mem.db.allocate calloc;
alias calloc alloca;
/+int _d_OutOfMemory() {
	return 0;
}+/
alias gc.free free;

