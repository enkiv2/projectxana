/+	node
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
import std.stdint;
import trans;
import doc;
import xu_db;
private import Memory;
import enfilade;
/+
struct XuHeap {
	uint size=0;
	Heap heap;
	uint start=0;
	void allocate(uint size) {
		heap.allocate(size);
		this.size+=size;
	}
	void* malloc(uint size) {
		uint x=heap.index;
		heap.allocate(size);
		this.size+=size;
		return &heap.memory[start+x];
	}
	void* opIndex(size_t i) {
		if (size > i) {
			return null;
		}
		return &heap.memory[start+i];
	}
	void opIndexApply(void* value, void* i) {
		copy((i+start), value, uint.sizeof);
	}
	uint[] opSlice(size_t start, size_t end) {
		return  heap.memory[this.start+start..this.start+end];
	}
	void opSliceAssign(void* value, size_t start, size_t end) {
		copy(value, &heap.memory[this.start+start], this.start+end-start);
	}
	uint[] opIndex() {
		return  heap.memory[0 .. size];
	}
	void opSliceAssign(void* value) {
		copy(value, &heap.memory[], value.sizeof);
	}
}
+/		
template XuNode (T) {
struct XuNode {
	uint size;
	T db;
	uint64_t[Enfilade][] loc;
	uint64_t[4][Enfilade] toc;
	uint64_t e0, e1, e2, e3;
	void init(T db) {
		this.db=db;
	}
	void fmt() {/+
		if (is (T == XuHeap)) {
			db.malloc(xudb.sizeof);
		}+/
		xudb x;
		db[]=*(cast(void[x.sizeof]*)(cast(void*)&x));
		init();
	}
	void init() {
		uint64_t toclen=cast(uint64_t) db[0];
		loc=cast(uint64_t[Enfilade][]) db[6 .. toclen];
		uint64_t start=6+toclen;
		e0=start;
		foreach (Enfilade e, uint64_t i; loc[0]) {
			start+=i;
			toc[e][0]=start;
		}
		e1=start;
		foreach (Enfilade e, uint64_t i; loc[1]) {
			start+=i;
			toc[e][1]=start;
		}
		e2=start;
		foreach (Enfilade e, uint64_t i; loc[2]) {
			start+=i;
			toc[e][2]=start;
		}
		e3=start;
		foreach (Enfilade e, uint64_t i; loc[3]) {
			start+=i;
			toc[e][3]=start;
		}
		size=start;
	}
	void recalcToc() {
		uint64_t start=6+loc.sizeof;
		e0=start;
		foreach (Enfilade e, uint64_t i; loc[0]) {
			start+=i;
			toc[e][0]=start;
		}
		e1=start;
		foreach (Enfilade e, uint64_t i; loc[1]) {
			start+=i;
			toc[e][1]=start;
		}
		e2=start;
		foreach (Enfilade e, uint64_t i; loc[2]) {
			start+=i;
			toc[e][2]=start;
		}
		e3=start;
		foreach (Enfilade e, uint64_t i; loc[3]) {
			start+=i;
			toc[e][2]=start;
		}
		size=start;
	}
	XuDoc get(Enfilade e) {
		if (toc[e]==null) {
			XuDoc t;
			return t;
		}
		uint64_t start=0;
		XuLink[] link=cast(XuLink[]) db[toc[e][0] .. toc[e][0]+loc[0][e]];
		XuClude[] trans=cast(XuClude[]) db[toc[e][1] .. toc[e][1]+loc[1][e]];
		Doc doc[]=cast(Doc[]) db[toc[e][2] .. toc[e][2]+loc[2][e]];
		char[] title=cast(char[]) db[toc[e][3] .. toc[e][3]+loc[2][e]];
		XuDoc fullDoc;
		fullDoc.doc=doc[0];
		fullDoc.links=link;
		fullDoc.cludes=trans;
		fullDoc.title=title;
		return fullDoc;
	}
	XuDoc add(XuDoc doc, Enfilade e) {
		uint64_t start=e0;
		uint64_t end=e1;
		XuLink[Enfilade][] links=cast(XuLink[Enfilade][]) db[start .. end];
		foreach (uint i, XuLink l; doc.links) {
			links[i][e]=l;
		}
		loc[0][e]=cast(uint64_t) doc.links.sizeof;
		start=end+doc.links.sizeof;
		end=e2;
		end+=doc.links.sizeof;
		XuClude[Enfilade][] trans=cast(XuClude[Enfilade][]) db[start .. end];
		foreach (uint i, XuClude c; doc.cludes) {
			trans[i][e]=c;
		}
		loc[1][e]=doc.cludes.sizeof;
		start=end+doc.cludes.sizeof;
		end=e3;
		end+=doc.cludes.sizeof;
		Doc[Enfilade][] docs=cast(Doc[Enfilade][]) db[start .. end];
		docs[0][e]=doc.doc;
		loc[2][e]=doc.doc.sizeof;
		XuTitle titles=cast(XuTitle) db[end .. db.length];
		foreach (uint i, char d; doc.title) {
			titles[i][e]=d;
		}
		loc[3][e]=doc.title.sizeof;
		recalcToc();
		return doc;
	}
	void free(Enfilade e) {
		XuDoc t;
		add(t, e);
	}
}
}
