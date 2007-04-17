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

struct Enfs {
	XuNode!(void[]) ram;
	XuNode!(MMPart) part;
	XuNode!(MMDisk) disk;
	enum MEDIA_TYPE {
		RAM,
		PART,
		DISK,
	}
	MEDIA_TYPE type;
	void init(void[] m) {
		type=MEDIA_TYPE.RAM;
		ram.init(m);
	}
	void init(MMPart m) {
		type=MEDIA_TYPE.PART;
		part.init(m);
	}
	void init(MMDisk m) {
		type=MEDIA_TYPE.DISK;
		disk.init(m);
	}
	void format() {
		switch (type) {
			RAM:
				ram.fmt();
				break;
			PART:
				part.fmt();
				break;
			DISK:
				disk.fmt();
				break;
		}
	}
	void setup() {
		switch(type) {
			RAM:
				ram.init();
				break;
			PART:
				part.init();
				break;
			DISK:
				disk.init();
				break;
		}
	}
	XuDoc get(Enfilade e) {
		switch(type) {
			RAM:
				return ram.get(e);
				break;
			PART:
				return part.get(e);
				break;
			DISK:
				return disk.get(e);
				break;
		}
		XuDoc doc;
		return doc;
	}
	XuDoc set(XuDoc doc, Enfilade e) {
		switch(type) {
			RAM:
				return ram.add(doc, e);
				break;
			PART:
				return part.add(doc, e);
				break;
			DISK:
				return disk.add(doc, e);
				break;
		}
		return newNull!(XuDoc)(doc);
	}
	void rm(Enfilade e) {
		switch(type) {
			RAM:
				ram.free(e);
				break;
			PART:
				part.free(e);
				break;
			DISK:
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
	
