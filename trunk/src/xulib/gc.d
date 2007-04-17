module std.gc;

//import node;
//import enfilade;
import std.stdint;
//import doc;
//import trans;
import util;
import gcstub;

import xulib.mem;

import Multiboot;

import kernel_assert;

static uint gstart;
static uint goff;
static uint gend;
static uint gc_disable;
static void* gc_handle;

static XuGC gc;

struct GCStats {
	uint poolsize;
	uint usedsize;
	uint freeblocks;
	uint freelistsize;
	uint pageblocks;
}
struct XuGC {
static xulib.mem.XuMem _mem;

void setFinalizer(void* p, void(*finalizer)(void* p, void* dummy)) {
	
}

void* malloc(uint size) {
	return _mem.malloc(size);
}

int capacity() {
	return _mem.heap.heap.memory.sizeof;
}

int capacity (byte* b) {
	return (capacity > cast(uint) *b);
}

void addRoot (void *p) { // add p to list of roots
/+	static Tumbler start;
	start[1]=1;
	start[2]=1;
	static Tumbler m;
	m[1]=cast(uint64_t) p;
	static Enfilade e;
	e.address[1]=start;
	e.address[2]=m;
	e.v=0;
	XuDoc d=mem.get(e);
	static XuLink l;
	XuLink[] links=d.links~l;
	d.links=links;
	d.doc.doc[0 .. p.sizeof]=cast(char[]) p[0 .. 0];
	mem.add(d, e);
	hasPointers(p);
+/
	_mem.addRoot(p);
}

void removeRoot (void *p) { // remove p from list of roots
/+
	static Tumbler start;
	start[1]=1;
	start[2]=1;
	static Tumbler m;
	m[1]=cast(uint64_t)p;
	static Enfilade e;
	e.address[1]=start;
	e.address[2]=m;
	e.v=0;
	XuDoc d=mem.get(e);
	XuLink[] l=d.links[0 .. length-1];
	if (l.length<=0) {
		hasNoPointers(p);
	} else {
		d.links=l;
		mem.add(d, e);
	}+/
	_mem.free(p, p.sizeof);
}

void addRange (void *pstart, void *pend) { // add range to scan for roots
/+
	static Tumbler start;
	start[1]=1;
	start[2]=1;
	static Tumbler m;
	m[1]=cast(uint64_t) pstart;
	static Enfilade e;
	e.address[1]=start;
	e.address[2]=m;
	e.v=0;
	static XuDoc d;
	uint psize=(cast(int)pend)-(cast(int)pstart);
	d.doc.doc=cast(char[])pstart[0 .. psize];
	static XuLink l;
	d.links=[l];
	mem.add(d, e);+/
	for (void* i=pstart; i<pend; i+=_mem.tablesize) {
		_mem.addRoot(i);
	}
}

void removeRange (void *p) { // remove range
//	hasNoPointers(p);	
	_mem.free(p, p.sizeof);
}

void hasPointers (void *p) { // mark a block as containing pointers
	/+ blank -- not needed +/
}

void hasNoPointers (void *p) { // mark a block as containing no pointers
/+	static XuDoc d;
	static Tumbler start;
	start[1]=1;
	start[2]=1;
	static Tumbler m;
	m[1]=cast(uint64_t) p;
	static Enfilade e;
	e.address[1]=start;
	e.address[2]=m;
	e.v=0;
	mem.add(d, e);+/
	_mem.free(p, p.sizeof);
}

void setTypeInfo (TypeInfo ti, void* p) { // mark a block as containing an 
					 // array of type ti (as many as will 
					 // fit in the block)
	/+ blank -- probably not needed +/
}

void fullCollect() { // Run a full collector cycle
/+
	if (!gc_disable) {
	static Tumbler start;
	start[1]=1;
	start[2]=1;
	static Tumbler mstart;
	mstart[1]=cast(uint64_t)1;
	static Tumbler mend;
	mend[1]=cast(uint64_t)mem.loc[2].length;
	static Enfilade estart;
	estart.address[1]=start;
	estart.address[2]=mstart;
	estart.v=0;
	static Enfilade eend;
	eend.address[1]=start;
	eend.address[2]=mend;
	eend.v=0;
	foreach (Enfilade e; estart>>eend) {
		if (isNull!(XuDoc)(mem.get(e))) {
			for (int i=0; i<mem.loc.length; i++) {
					mem.db[mem.toc[e][i] .. mem.loc[i][e]+mem.toc[e][i]]=null;
				mem.loc[i][e]=0;
				mem.recalcToc();
			}
		}
	}
	}+/
	// not needed
}

void genCollect() { // run a generational cycle
/+	if (!gc_disable) {
	static Tumbler start;
	start[1]=1;
	start[2]=1;
	static Tumbler mstart;
	mstart[1]=cast(uint64_t) gstart;
	static Tumbler mend;
	mend[1]=cast(uint64_t) gend;
	static Enfilade estart;
	estart.address[1]=start;
	estart.address[2]=mstart;
	estart.v=0;
	static Enfilade eend;
	eend.address[1]=start;
	eend.address[2]=mend;
	eend.v=0;
	foreach (Enfilade e; estart>>eend) {
		if (isNull!(XuDoc)(mem.get(e))) {
			for (int i=0; i<mem.loc.length; i++) {
				mem.db[mem.toc[e][i] .. mem.loc[i][e]+mem.toc[e][i]]=null;
				mem.loc[i][e]=0;
				mem.recalcToc();
			}
		}
	}
	if (gstart>= mem.db.size-1) {
		gstart=0;
		gend=goff;
	} else {
		gstart=gend+1;
		gend=gstart+goff;
		if (gend >= mem.db.size) {
			gend=mem.db.size-1;
		}
	}
	}+/
	// not needed
}

void genCollectNoStack() { 
	genCollect();
}

void minimize() { // minimize physical memory usage
	fullCollect();
}

void disable() { // disables gc cycle
	gc_disable++;
}

void enable() { // enables gc cycle
	gc_disable--;
}

void getStats (out GCStats stats) {
	stats.poolsize=capacity();
	stats.usedsize=_mem.index*_mem.tablesize;
	stats.freeblocks=stats.poolsize-stats.usedsize;
	stats.freelistsize=stats.freeblocks;
	stats.pageblocks=0;
}

void* getGCHandle() { // get collector handle
	return &gc_handle;
}

void setGCHandle(void *p) { // set collector handle
	gc_handle=p;
}

void endGCHandle() { 
	disable();
}

extern (C) {
	void gc_init() {
//		kernel_assert.kernel_assert(0!=0, "gc.d\0", "249\0");
		_mem.heap.start=0x00100000+0x800000;
		_mem.init(0x0ff);/+
		gstart=0;
		goff=mem.db.size;
		gend=goff;+/
//		kernel_assert.kernel_assert(0!=0, "gc.d\0", "255\0");
		setGCHandle(this);
//		kernel_assert.kernel_assert(0!=0, "gc.d\0", "257\0");
		gc_disable=0;
	}
	void gc_term() {
		disable();
	}
}
void free(void* p) {
	hasNoPointers(p);
}
void* calloc(uint addr, int size) {
	return malloc(size);
}
}

void free(void* p) {
	gc.hasNoPointers(p);
}
