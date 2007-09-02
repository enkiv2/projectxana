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
import kernel_assert;
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
	uint64_t[Enfilade][] toc;
//	uint64_t e0, e1, e2, e3;
	void init(T db) {
		this.db=db;
	}
	void fmt() {/+
		if (is (T == XuHeap)) {
			db.malloc(xudb.sizeof);
		}+///kernel_assert.kernel_assert(1, "node.d", "64");
		xudb x; //kernel_assert.kernel_assert(1, "node.d", "65");
		db[]=*(cast(void[x.sizeof]*)(cast(void*)&x));
		init();
	}
	void init() {//kernel_assert.kernel_assert(1, "node.d", "69");
		uint64_t toclen=cast(uint64_t) db[0];
		//kernel_assert.kernel_assert(1, "node.d", "70");
		loc=cast(uint64_t[Enfilade][]) db[6 .. toclen]; //kernel_assert.kernel_assert(1, "node.d", "72");
		uint64_t start=6+toclen; //kernel_assert.kernel_assert(1, "node.d", "73");
//		e0=start;
		foreach (Enfilade e, uint64_t i; loc[0]) {
			kernel_assert.kernel_assert(1, "node.d", "76");
			start+=i;
			toc[0][e]=start;
		}
/+		e1=start;
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
+/		size=start;
	}
	void recalcToc() {
		uint64_t start=6+loc.sizeof;
//		e0=start;
		foreach (Enfilade e, uint64_t i; loc[0]) {
			start+=i;
			toc[0][e]=start;
		}
/+		e1=start;
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
+/		size=start;
	}
	XuDoc get(Enfilade e) {
		if (toc[0][e]==0) {
			XuDoc t;
			return t;
		}
		uint64_t start=0;
		XuDoc fullDoc=(cast(XuDoc[]) db[toc[0][e] .. toc[0][e]+loc[0][e]])[0];
/+		XuClude[] trans=cast(XuClude[]) db[toc[e][1] .. toc[e][1]+loc[1][e]];
		Doc doc[]=cast(Doc[]) db[toc[e][2] .. toc[e][2]+loc[2][e]];
		char[] title=cast(char[]) db[toc[e][3] .. toc[e][3]+loc[2][e]];
		XuDoc fullDoc;
		fullDoc.doc=doc[0];
		fullDoc.links=link;
		fullDoc.cludes=trans;
		fullDoc.title=title;
+/		return fullDoc;
	}
	XuDoc add(XuDoc doc, Enfilade e) {
		uint64_t start=size;
//		uint64_t end=e1;
/+		XuLink[Enfilade][] links=cast(XuLink[Enfilade][]) db[start .. end];
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
+/
		XuDoc[] doc2;
		doc2[0]=doc;
		db[start .. doc.sizeof]=cast(void[])(doc2);
		loc[0][e]=doc.sizeof;
		recalcToc();
		return doc;
	}
	void free(Enfilade e) {
		XuDoc t;
		add(t, e);
	}
}
}
