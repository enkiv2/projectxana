/+	enfs
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/

import node;
import xulib.mem;
import mmdisk;
import enfilade;
import doc;
import trans;
import util;

private static const int RAM=0;
private static const int PART=1;
private static const int DISK=2;

struct Enfs {
	XuNode!(void[]) ram;
	XuNode!(MMPart) part;
	XuNode!(MMDisk) disk;
	enum MEDIA_TYPE:int{
		RAM=0,
		PART,
		DISK,
	}
	int type;
	void init(void[] m) {
		type=RAM;
		ram.init(m);
	}
	void init(MMPart m) {
		type=PART;
		part.init(m);
	}
	void init(MMDisk m) {
		type=DISK;
		disk.init(m);
	}
	void format() {
//		kernel_assert.kernel_assert(1, "enfs.d", "38");
		switch (type) {
			case 0:	
				//kernel_assert.kernel_assert(1, "enfs.d", "45");
				ram.fmt();
				break;
			case 1:
				part.fmt();
				break;
			case 2:
				disk.fmt();
				break;
		}
	}
	void setup() {
		switch(type) {
			case 0:
				ram.init();
				break;
			case 1:
				part.init();
				break;
			case 2:
				disk.init();
				break;
		}
	}
	XuDoc get(Enfilade e) {
		switch(type) {
			case 0:
				return ram.get(e);
				break;
			case 1:
				return part.get(e);
				break;
			case 2:
				return disk.get(e);
				break;
		}
		XuDoc doc;
		return doc;
	}
	XuDoc set(XuDoc doc, Enfilade e) {
		switch(type) {
			case 0:
				return ram.add(doc, e);
				break;
			case 1:
				return part.add(doc, e);
				break;
			case 2:
				return disk.add(doc, e);
				break;
		}
		return newNull!(XuDoc)(doc);
	}
	void rm(Enfilade e) {
		switch(type) {
			case 0:
				ram.free(e);
				break;
			case 1:
				part.free(e);
				break;
			case 2:
				disk.free(e);
				break;
		}
	}
	XuDoc add(XuDoc doc, Enfilade e) {
		while (!(isNull!(XuDoc)(this.get(e)))) {
			e.v++;
		}
		return this.set(doc, e);
	}
}
	
