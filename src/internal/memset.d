/+
/*
 *  Copyright (C) 2004 by Digital Mars, www.digitalmars.com
 *  Written by Walter Bright
 *
 *  This software is provided 'as-is', without any express or implied
 *  warranty. In no event will the authors be held liable for any damages
 *  arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute it
 *  freely, in both source and binary form, subject to the following
 *  restrictions:
 *
 *  o  The origin of this software must not be misrepresented; you must not
 *     claim that you wrote the original software. If you use this software
 *     in a product, an acknowledgment in the product documentation would be
 *     appreciated but is not required.
 *  o  Altered source versions must be plainly marked as such, and must not
 *     be misrepresented as being the original software.
 *  o  This notice may not be removed or altered from any source
 *     distribution.
 */

/* NOTE: This file has been patched from the original DMD distribution to
   work with the GDC compiler.

   Modified by David Friedman, September 2004
*/

extern (C)
{
    // Functions from the C library.
    void *memcpy(void *, void *, uint);
    void *memset(void *, int, uint);
    int memcmp(void*, void*, uint);
}
extern (C) void *memmove(void* x, void* y, uint  l) {
    	return memcpy(x, y, l);
}

extern (C):

short *_memset16(short *p, short value, int count)
{
    short *pstart = p;
    short *ptop;

    for (ptop = &p[count]; p < ptop; p++)
	*p = value;
    return pstart;
}

int *_memset32(int *p, int value, int count)
{
version (Asm86)
{
    asm
    {
	mov	EDI,p		;
	mov	EAX,value	;
	mov	ECX,count	;
	mov	EDX,EDI		;
	rep			;
	stosd			;
	mov	EAX,EDX		;
    }
}
else
{
    int *pstart = p;
    int *ptop;

    for (ptop = &p[count]; p < ptop; p++)
	*p = value;
    return pstart;
}
}

long *_memset64(long *p, long value, int count)
{
    long *pstart = p;
    long *ptop;

    for (ptop = &p[count]; p < ptop; p++)
	*p = value;
    return pstart;
}

cdouble *_memset128(cdouble *p, cdouble value, int count)
{
    cdouble *pstart = p;
    cdouble *ptop;

    for (ptop = &p[count]; p < ptop; p++)
	*p = value;
    return pstart;
}

real *_memset80(real *p, real value, int count)
{
    real *pstart = p;
    real *ptop;

    for (ptop = &p[count]; p < ptop; p++)
	*p = value;
    return pstart;
}

creal *_memset160(creal *p, creal value, int count)
{
    creal *pstart = p;
    creal *ptop;

    for (ptop = &p[count]; p < ptop; p++)
	*p = value;
    return pstart;
}

void *_memsetn(void *p, void *value, int count, int sizelem)
{   void *pstart = p;
    int i;

    for (i = 0; i < count; i++)
    {
	memcpy(p, value, sizelem);
	p = cast(void *)(cast(char *)p + sizelem);
    }
    return pstart;
}
+/
