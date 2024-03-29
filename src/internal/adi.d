//_ adi.d

/**
 * Part of the D programming language runtime library.
 * Dynamic array property support routines
 */

/*
 *  Copyright (C) 2000-2006 by Digital Mars, www.digitalmars.com
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

   Modified by David Friedman, April 2005
*/

//debug=adi;		// uncomment to turn on debugging printf's

/+import std.stdio;
import std.c.stdio;
import std.c.stdlib;
import std.c.string;
import std.string;
import std.outofmemory;
import std.utf;+/

import object;
alias bool bit;
import std.string;
import std.stdio;
import std.c.stdio;
//import memset;
import std.memory;

struct Array
{
    size_t length;
    void* ptr;
}

/**********************************************
 * Reverse array of chars.
 * Handled separately because embedded multibyte encodings should not be
 * reversed.
 */

extern (C) Array _adReverseChar(char[] a)
{
    if (a.length > 1)
    {
	char[6] tmp;
	char[6] tmplo;
	char* lo = a.ptr;
	char* hi = &a[length - 1];

	while (lo < hi)
	{   auto clo = *lo;
	    auto chi = *hi;

	    //printf("lo = %d, hi = %d\n", lo, hi);
	    if (clo <= 0x7F && chi <= 0x7F)
	    {
		//printf("\tascii\n");
		*lo = chi;
		*hi = clo;
		lo++;
		hi--;
		continue;
	    }

//	    int stridelo = std.utf.UTF8stride[clo];

	    int stridehi = 1;
	    while ((chi & 0xC0) == 0x80)
	    {
		chi = *--hi;
		stridehi++;
		assert(hi >= lo);
	    }
	    if (lo == hi)
		break;

	    //printf("\tstridelo = %d, stridehi = %d\n", stridelo, stridehi);
//	    if (stridelo == stridehi)
//	    {

//		memcpy(tmp.ptr, lo, stridelo);
//		memcpy(lo, hi, stridelo);
//		memcpy(hi, tmp.ptr, stridelo);
//		lo += stridelo;
//		hi--;
//		continue;
//	    }

	    /* Shift the whole array. This is woefully inefficient
	     */
//	    memcpy(tmp.ptr, hi, stridehi);
//	    memcpy(tmplo.ptr, lo, stridelo);
//	    memmove(lo + stridehi, lo + stridelo , hi - (lo + stridelo));
//	    memcpy(lo, tmp.ptr, stridehi);
//	    memcpy(hi + stridehi - stridelo, tmplo.ptr, stridelo);

//	    lo += stridehi;
//	    hi = hi - 1 + (stridehi - stridelo);
	}
    }
    return *cast(Array*)(&a);
}
/+
unittest
{
    char[] a = "abcd";
    char[] r;

    r = a.dup.reverse;
    //writefln(r);
    assert(r == "dcba");

    a = "a\u1235\u1234c";
    //writefln(a);
    r = a.dup.reverse;
    //writefln(r);
    assert(r == "c\u1234\u1235a");

    a = "ab\u1234c";
    //writefln(a);
    r = a.dup.reverse;
    //writefln(r);
    assert(r == "c\u1234ba");

    a = "\u3026\u2021\u3061\n";
    r = a.dup.reverse;
    assert(r == "\n\u3061\u2021\u3026");
}
+/

/**********************************************
 * Reverse array of wchars.
 * Handled separately because embedded multiword encodings should not be
 * reversed.
 */

extern (C) Array _adReverseWchar(wchar[] a)
{
    if (a.length > 1)
    {
	wchar[2] tmp;
	wchar* lo = a.ptr;
	wchar* hi = &a[length - 1];

	while (lo < hi)
	{   auto clo = *lo;
	    auto chi = *hi;

	    if ((clo < 0xD800 || clo > 0xDFFF) &&
		(chi < 0xD800 || chi > 0xDFFF))
	    {
		*lo = chi;
		*hi = clo;
		lo++;
		hi--;
		continue;
	    }

	    int stridelo = 1 + (clo >= 0xD800 && clo <= 0xDBFF);

	    int stridehi = 1;
	    if (chi >= 0xDC00 && chi <= 0xDFFF)
	    {
		chi = *--hi;
		stridehi++;
		assert(hi >= lo);
	    }
	    if (lo == hi)
		break;

	    if (stridelo == stridehi)
	    {	int stmp;

		assert(stridelo == 2);
		assert(stmp.sizeof == 2 * (*lo).sizeof);
		stmp = *cast(int*)lo;
		*cast(int*)lo = *cast(int*)hi;
		*cast(int*)hi = stmp;
		lo += stridelo;
		hi--;
		continue;
	    }

	    /* Shift the whole array. This is woefully inefficient
	     */
	    memcpy(tmp.ptr, hi, stridehi * wchar.sizeof);
	    memcpy(hi + stridehi - stridelo, lo, stridelo * wchar.sizeof);
	    memmove(lo + stridehi, lo + stridelo , (hi - (lo + stridelo)) * wchar.sizeof);
	    memcpy(lo, tmp.ptr, stridehi * wchar.sizeof);

	    lo += stridehi;
	    hi = hi - 1 + (stridehi - stridelo);
	}
    }
    return *cast(Array*)(&a);
}
/+
unittest
{
    wchar[] a = "abcd";
    wchar[] r;

    r = a.dup.reverse;
    assert(r == "dcba");

    a = "a\U00012356\U00012346c";
    r = a.dup.reverse;
    assert(r == "c\U00012346\U00012356a");

    a = "ab\U00012345c";
    r = a.dup.reverse;
    assert(r == "c\U00012345ba");
}
+/
// %% Had to move _adCmpChar to the beginning of the file
// due to a extern/static symbol conflict on darwin...
/***************************************
 * Support for array compare test.
 */

extern (C) int _adCmpChar(Array a1, Array a2)
{
version (Asm86)
{
    asm
    {	naked			;

        push    EDI		;
        push    ESI		;

        mov    ESI,a1+4[4+ESP]	;
        mov    EDI,a2+4[4+ESP]	;

        mov    ECX,a1[4+ESP]	;
        mov    EDX,a2[4+ESP]	;

	cmp	ECX,EDX		;
	jb	GotLength	;

	mov	ECX,EDX		;

GotLength:
        cmp    ECX,4		;
        jb    DoBytes		;

        // Do alignment if neither is dword aligned
        test    ESI,3		;
        jz    Aligned		;

        test	EDI,3		;
        jz    Aligned		;
DoAlign:
        mov    AL,[ESI]		; //align ESI to dword bounds
        mov    DL,[EDI]		;

        cmp    AL,DL		;
        jnz    Unequal		;

        inc    ESI		;
        inc    EDI		;

        test    ESI,3		;

        lea    ECX,[ECX-1]	;
        jnz    DoAlign		;
Aligned:
        mov    EAX,ECX		;

	// do multiple of 4 bytes at a time

        shr    ECX,2		;
        jz    TryOdd		;

        repe			;
	cmpsd			;

        jnz    UnequalQuad	;

TryOdd:
        mov    ECX,EAX		;
DoBytes:
	// if still equal and not end of string, do up to 3 bytes slightly
	// slower.

        and    ECX,3		;
        jz    Equal		;

        repe			;
	cmpsb			;

        jnz    Unequal		;
Equal:
        mov    EAX,a1[4+ESP]	;
        mov    EDX,a2[4+ESP]	;

        sub    EAX,EDX		;
        pop    ESI		;

        pop    EDI		;
        ret			;

UnequalQuad:
        mov    EDX,[EDI-4]	;
        mov    EAX,[ESI-4]	;

        cmp    AL,DL		;
        jnz    Unequal		;

        cmp    AH,DH		;
        jnz    Unequal		;

        shr    EAX,16		;

        shr    EDX,16		;

        cmp    AL,DL		;
        jnz    Unequal		;

        cmp    AH,DH		;
Unequal:
        sbb    EAX,EAX		;
        pop    ESI		;

        or     EAX,1		;
        pop    EDI		;

        ret			;
    }
}
else
{
    int len;
    int c;

    //printf("adCmpChar()\n");
    len = a1.length;
    if (a2.length < len)
	len = a2.length;
    c =memcmp(a1.ptr, a2.ptr, cast(uint)len);
    if (!c)
	c = cast(int)a1.length - cast(int)a2.length;
    return c;
}
}
/+
unittest
{
    debug(adi) printf("array.CmpChar unittest\n");

    char[] a = "hello";

    assert(a >  "hel");
    assert(a >= "hel");
    assert(a <  "helloo");
    assert(a <= "helloo");
    assert(a >  "betty");
    assert(a >= "betty");
    assert(a == "hello");
    assert(a <= "hello");
    assert(a >= "hello");
}
+/

/**********************************************
 * Support for array.reverse property.
 */

extern (C) Array _adReverse(Array a, int szelem)
    out (result)
    {
	assert(result is a);
    }
    body
    {
	if (a.length >= 2)
	{
	    byte* tmp;
	    byte[16] buffer;

	    void* lo = a.ptr;
	    void* hi = a.ptr + (a.length - 1) * szelem;

	    tmp = buffer.ptr;
	    if (szelem > 16)
	    {
		//version (Win32)
		    tmp = cast(byte*) alloca(szelem);
		//else
		    //tmp = new byte[szelem];
	    }

	    for (; lo < hi; lo += szelem, hi -= szelem)
	    {
		memcpy(tmp, lo,  szelem);
		memcpy(lo,  hi,  szelem);
		memcpy(hi,  tmp, szelem);
	    }

	    version (Win32)
	    {
	    }
	    else
	    {
		//if (szelem > 16)
		    // BUG: bad code is generate for delete pointer, tries
		    // to call delclass.
		    //delete tmp;
	    }
	}
	return a;
    }
/+
unittest
{
    debug(adi) printf("array.reverse.unittest\n");

    int[] a = new int[5];
    int[] b;
    int i;

    for (i = 0; i < 5; i++)
	a[i] = i;
    b = a.reverse;
    assert(b is a);
    for (i = 0; i < 5; i++)
	assert(a[i] == 4 - i);

    struct X20
    {	// More than 16 bytes in size
	int a;
	int b, c, d, e;
    }

    X20[] c = new X20[5];
    X20[] d;

    for (i = 0; i < 5; i++)
    {	c[i].a = i;
	c[i].e = 10;
    }
    d = c.reverse;
    assert(d is c);
    for (i = 0; i < 5; i++)
    {
	assert(c[i].a == 4 - i);
	assert(c[i].e == 10);
    }
}
+/
/**********************************************
 * Support for array.reverse property for bit[].
 */

version (none)
{
extern (C) bit[] _adReverseBit(bit[] a)
    out (result)
    {
	assert(result is a);
    }
    body
    {
	if (a.length >= 2)
	{
	    bit t;
	    int lo, hi;

	    lo = 0;
	    hi = a.length - 1;
	    for (; lo < hi; lo++, hi--)
	    {
		t = a[lo];
		a[lo] = a[hi];
		a[hi] = t;
	    }
	}
	return a;
    }
/+
unittest
{
    debug(adi) printf("array.reverse_Bit[].unittest\n");

    bit[] b;
    b = new bit[5];
    static bit[5] data = [1,0,1,1,0];
    int i;

    b[] = data[];
    b.reverse;
    for (i = 0; i < 5; i++)
    {
	assert(b[i] == data[4 - i]);
    }
}
+/
}
/**********************************************
 * Sort array of chars.
 */

extern (C) char[] _adSortChar(char[] a)
{
//    if (a.length > 1)
//    {
//	dchar[] da = toUTF32(a);
//	da.sort;
//	size_t i = 0;
//	foreach (dchar d; da)
//	{   char[4] buf;
//	    char[] t = buf;
//	    a[i .. i + t.length] = t[];
//	    i += t.length;
//	}
//	delete da;
//    }
    return a;
}

/**********************************************
 * Sort array of wchars.
 */

extern (C) wchar[] _adSortWchar(wchar[] a)
{
//    if (a.length > 1)
//  {
//	dchar[] da = toUTF32(a);
//	da.sort;
//	size_t i = 0;
//	foreach (dchar d; da)
//	{   wchar[2] buf;
//	    wchar[] t = toUTF16(buf, d);
//	    a[i .. i + t.length] = t[];
//	    i += t.length;
//	}
//	delete da;
//  }
    return a;
}

/**********************************************
 * Support for array.sort property for bit[].
 */

extern (C) bit[] _adSortBit(bit[] a)
    out (result)
    {
	assert(result is a);
    }
    body
    {
	if (a.length >= 2)
	{
	    size_t lo, hi;

	    lo = 0;
	    hi = a.length - 1;
	    while (1)
	    {
		while (1)
		{
		    if (lo >= hi)
			goto Ldone;
		    if (a[lo] == true)
			break;
		    lo++;
		}

		while (1)
		{
		    if (lo >= hi)
			goto Ldone;
		    if (a[hi] == false)
			break;
		    hi--;
		}

		a[lo] = false;
		a[hi] = true;

		lo++;
		hi--;
	    }
	Ldone:
	    ;
	}
	return a;
    }
/+
unittest
{
    debug(adi) printf("array.sort_Bit[].unittest\n");
}
+/

/***************************************
 * Support for array equality test.
 */

extern (C) int _adEq(Array a1, Array a2, TypeInfo ti)
{
    //printf("_adEq(a1.length = %d, a2.length = %d)\n", a1.length, a2.length);
    if (a1.length != a2.length)
	return 0;		// not equal
    auto sz = ti.sizeof;
    auto p1 = a1.ptr;
    auto p2 = a2.ptr;

/+
    for (int i = 0; i < a1.length; i++)
    {
	printf("%4x %4x\n", (cast(short*)p1)[i], (cast(short*)p2)[i]);
    }
+/

    if (sz == 1)
	// We should really have a ti.isPOD() check for this
	return (memcmp(&p1, &p2, a1.length) == 0);

    for (size_t i = 0; i < a1.length; i++)
    {
	if ((p1 + i * sz == p2 + i * sz))
	    return 0;		// not equal
    }
    return 1;			// equal
}
/+
unittest
{
    debug(adi) printf("array.Eq unittest\n");

    char[] a = "hello";

    assert(a != "hel");
    assert(a != "helloo");
    assert(a != "betty");
    assert(a == "hello");
    assert(a != "hxxxx");
}
+/
/***************************************
 * Support for array equality test for bit arrays.
 */

version (none)
{
extern (C) int _adEqBit(Array a1, Array a2)
{   int i;

    if (a1.length != a2.length)
	return 0;		// not equal
    auto p1 = cast(ubyte*)a1.ptr;
    auto p2 = cast(ubyte*)a2.ptr;
    auto n = a1.length / 8;
    for (i = 0; i < n; i++)
    {
	if (p1[i] != p2[i])
	    return 0;		// not equal
    }

    ubyte mask;

    n = a1.length & 7;
    mask = cast(ubyte)((1 << n) - 1);
    //printf("i = %d, n = %d, mask = %x, %x, %x\n", i, n, mask, p1[i], p2[i]);
    return (mask == 0) || (p1[i] & mask) == (p2[i] & mask);
}
/+
unittest
{
    debug(adi) printf("array.EqBit unittest\n");

    static bit[] a = [1,0,1,0,1];
    static bit[] b = [1,0,1];
    static bit[] c = [1,0,1,0,1,0,1];
    static bit[] d = [1,0,1,1,1];
    static bit[] e = [1,0,1,0,1];

    assert(a != b);
    assert(a != c);
    assert(a != d);
    assert(a == e);
}
+/
}

/***************************************
 * Support for array compare test.
 */

extern (C) int _adCmp(Array a1, Array a2, TypeInfo ti)
{
    //printf("adCmp()\n");
    auto len = a1.length;
    if (a2.length < len)
	len = a2.length;
    auto sz = ti.sizeof;
    void *p1 = a1.ptr;
    void *p2 = a2.ptr;

    if (sz == 1)
    {	// We should really have a ti.isPOD() check for this
	auto c = memcmp(&p1, &p2, len);
	if (c)
	    return c;
    }
    else
    {
	for (size_t i = 0; i < len; i++)
	{
	    auto c = (p1 + i * sz > p2 + i * sz);
	    if (c)
		return c;
	}
    }
    if (a1.length == a2.length)
	return 0;
    return (a1.length > a2.length) ? 1 : -1;
}
/+
unittest
{
    debug(adi) printf("array.Cmp unittest\n");

    char[] a = "hello";

    assert(a >  "hel");
    assert(a >= "hel");
    assert(a <  "helloo");
    assert(a <= "helloo");
    assert(a >  "betty");
    assert(a >= "betty");
    assert(a == "hello");
    assert(a <= "hello");
    assert(a >= "hello");
}
+/

/***************************************
 * Support for array compare test.
 */

version (none)
{
extern (C) int _adCmpBit(Array a1, Array a2)
{
    int len;
    uint i;

    len = a1.length;
    if (a2.length < len)
	len = a2.length;
    ubyte *p1 = cast(ubyte*)a1.ptr;
    ubyte *p2 = cast(ubyte*)a2.ptr;
    uint n = len / 8;
    for (i = 0; i < n; i++)
    {
	if (p1[i] != p2[i])
	    break;		// not equal
    }
    for (uint j = i * 8; j < len; j++)
    {	ubyte mask = cast(ubyte)(1 << j);
	int c;

	c = cast(int)(p1[i] & mask) - cast(int)(p2[i] & mask);
	if (c)
	    return c;
    }
    return cast(int)a1.length - cast(int)a2.length;
}
/+
unittest
{
    debug(adi) printf("array.CmpBit unittest\n");

    static bit[] a = [1,0,1,0,1];
    static bit[] b = [1,0,1];
    static bit[] c = [1,0,1,0,1,0,1];
    static bit[] d = [1,0,1,1,1];
    static bit[] e = [1,0,1,0,1];

    assert(a >  b);
    assert(a >= b);
    assert(a <  c);
    assert(a <= c);
    assert(a <  d);
    assert(a <= d);
    assert(a == e);
    assert(a <= e);
    assert(a >= e);
}
+/
}

