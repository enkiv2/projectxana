/+	xulib.mem
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
module xulib.mem;

//import node;
import Memory;
import heap;

struct XuMem {
	XuHeap heap;
	uint* memtable;
	uint tablesize=4096;
	uint index;
	uint memtablesize;
	void init(uint size) {
		memtablesize=size;
		memtable=cast(uint*)heap.malloc(size);
		index=0;
	}
	void* malloc(uint size) {
		void* temp;
		if (heap.size+size < (cast(uint)memtable)+memtablesize+(index*tablesize)) {
			temp=heap.malloc(size);
		} else {
			temp=cast(void*)(memtable+memtablesize+(index*tablesize));
		}
		for (int i=0; i<=size/tablesize; i++) {
			*((memtable)+index)=*((cast(uint*)temp)+(i*tablesize));
			index++;
			(*(memtable+index))=1;
			index++;
		}
		return temp;
	}
	void free(void* temp, uint size) {
		for (int i=0; i<index; i+=2) {
			if ((*(memtable+i))==*(cast(uint*)temp)) {
				(*(memtable+i+1))=(*(memtable+i+1))--;
				if ((*(memtable+i+1))<=0) {
					memcpy((memtable+i), (memtable+(i+size)), size);
					index-=(size/tablesize)+1;
				}
			}
		}
	}
	void addRoot(void* temp) {
		for (int i=0; i<index; i+=2) {
			if ((*(memtable+i))==(cast(uint)temp)) {
				(*(memtable+(i+1)))++;
			}
		}
	}
}

