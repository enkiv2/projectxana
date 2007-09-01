/+	Memory
 +	(c) 2007 Alexander Panek
 +	Licensed under the ZLIB license
 +	Part of Project XANA
 +/
module Memory;

/* temporary heap implementation */
struct Heap {
	static:

	size_t [0x10000] memory;
	uint index;

	/*
		This is a very very very simple allocator.
		It increases the index by size, and returns a pointer to memory[oldIndex].
	 */
	uint * allocate ( uint size ) {
		Heap heap;

		if ( size > heap.memory.sizeof ) {
			ubyte s = (size / 4) + (size % 4);

			heap.index += s;

			return &heap.memory[heap.index - s];
		} else {
			heap.index++;

			return &heap.memory[heap.index - 1];
		}

	}
	
	/+
	void free ( uint * ) {
		
	}
	+/
}

Heap heap;

extern (C) void memmove( void * src, void * dst, uint size) {
	memcpy (src, dst, size);
}

extern (C) void memcpy ( void * src, void * dst, uint size ) {
    uint * plDst = cast(uint *) dst;
    uint * plSrc = cast(uint *) src;

    if (!(cast(uint)src & 0xFFFFFFFC) && !(cast(uint)dst & 0xFFFFFFFC)) {
        while (size >= plDst.sizeof) {
            *plDst++ = *plSrc++;
            size -= plDst.sizeof;
        }
    }
    
    ubyte *pcDst = cast(ubyte *)plDst;
    ubyte *pcSrc = cast(ubyte *)plSrc;
    
    while (--size){
        *pcDst++ = *pcSrc++;
    }
    
    return dst;
}



public void copy( void * src, void * dest, uint length ) {
	memcpy( src, dest, length );
}

extern(C) void _d_array_bounds ( ) { }

void memset (void* dest, ubyte src, uint times) {
	uint i=0;
	while (times--) {
		*(cast(ubyte*)(dest+(i++)))=src;
	}
}

extern (C) void memset (void* dest, uint src, uint times) {
	uint i=0;
	while (times--) {
		*(cast(uint*)(dest+(i++)))=src;
	}
}


/+
void set ( T ) ( in T source, in T destination, in uint times ) {
	uint i = 0;

	while ( times-- ) {
		destination[i++] = source;
	}
}

void set ( T, U ) ( in T source, in U * destination, in uint times ) {
	uint i = 0;

	while ( times-- ) {
		destination[i++] = cast(U)source;
	}
}

void copy ( T ) ( in T * source, in T * destination, in uint length ) {
	uint i = length % T.sizeof;

	T * src = source;
	T * dest = destination;

	if ( i ) {
		for( uint j = 0; j < i; j++ ) {
			(cast(T[])dest)[j]  = (cast(T[])src)[j];
		}
	}

	while ( length -= T.sizeof ) {
		*src++ = *dest++;
	}
}
+/

//alias compare!(void*) memcmp;

uint compare ( T ) ( in T m1, in T m2, in uint length ) {
	while ( *m1++ == *m2++ ) {
		if ( length < T.sizeof ) {
			ubyte *_m1 = cast(ubyte *)m1;
			ubyte *_m2 = cast(ubyte *)m2;

			while( *_m1++ == *_m2++ ) {
				length--;
			}

			break;
		}

		length -= T.sizeof;
	}

	return length;
}

extern (C) uint memcmp (void* m1, void* m2, uint length) {
	while (*(cast(ubyte*)(m1++)) == *(cast(ubyte*)(m2++))) {
		length--;
	}
	return length;
}

