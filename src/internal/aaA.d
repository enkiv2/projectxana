//_ aaA.d

/**
 * Part of the D programming language runtime library.
 * Implementation of associative arrays.
 */

/*
 *  Copyright (C) 2000-2007 by Digital Mars, www.digitalmars.com
 *  Written by Walter Bright
 *
 *  This software is provided 'as-is', without any express or implied
 *  warranty. In no event will the authors be held liable for any damages
 *  arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute it
 *  freely, subject to the following restrictions:
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
/+
import std.c.stdio;
import std.c.stdlib;
import std.c.string;
import std.string;
import std.outofmemory;
+/
// Auto-rehash and pre-allocate - Dave Fladebo
import object;
import std.memory;

//extern (D) {
static uint[] prime_list = [
    97UL,         389UL,
    1543UL,       6151UL,
    24593UL,      98317UL,
    393241UL,     1572869UL,
    6291469UL,    25165843UL,
    100663319UL,  402653189UL,
    1610612741UL, 4294967291UL
];

/* This is the type of the return value for dynamic arrays.
 * It should be a type that is returned in registers.
 * Although DMD will return types of Array in registers,
 * gcc will not, so we instead use a 'long'.
 */
alias long ArrayRet_t;

struct Array
{
    size_t length;
    void* ptr;
}

struct aaA
{
    aaA *left;
    aaA *right;
    hash_t hash;
    /* key   */
    /* value */
}

struct BB
{
    aaA*[] b;
    size_t nodes;	// total number of aaA nodes
}

/* This is the type actually seen by the programmer, although
 * it is completely opaque.
 */

struct AA
{
    BB* a;
    version (X86_64)
    {
    }
    else
    {
	// This is here only to retain binary compatibility with the
	// old way we did AA's. Should eventually be removed.
	//int reserved;
    }
}

/**********************************
 * Align to next pointer boundary, so that
 * GC won't be faced with misaligned pointers
 * in value.
 */

size_t aligntsize(size_t tsize)
{
    // Is pointer alignment on the x64 4 bytes or 8?
    return (tsize + size_t.sizeof - 1) & ~(size_t.sizeof - 1);
}
//}

/*************************************************
 * Invariant for aa.
 */

/*
void _aaInvAh(aaA*[] aa)
{
    for (size_t i = 0; i < aa.length; i++)
    {
	if (aa[i])
	    _aaInvAh_x(aa[i]);
    }
}

private int _aaCmpAh_x(aaA *e1, aaA *e2)
{   int c;

    c = e1.hash - e2.hash;
    if (c == 0)
    {
	c = e1.key.length - e2.key.length;
	if (c == 0)
	    c = memcmp((char *)e1.key, (char *)e2.key, e1.key.length);
    }
    return c;
}

private void _aaInvAh_x(aaA *e)
{
    hash_t key_hash;
    aaA *e1;
    aaA *e2;

    key_hash = getHash(e.key);
    assert(key_hash == e.hash);

    while (1)
    {   int c;

	e1 = e.left;
	if (e1)
	{
	    _aaInvAh_x(e1);		// ordinary recursion
	    do
	    {
		c = _aaCmpAh_x(e1, e);
		assert(c < 0);
		e1 = e1.right;
	    } while (e1 != null);
	}

	e2 = e.right;
	if (e2)
	{
	    do
	    {
		c = _aaCmpAh_x(e, e2);
		assert(c < 0);
		e2 = e2.left;
	    } while (e2 != null);
	    e = e.right;		// tail recursion
	}
	else
	    break;
    }
}
*/

/****************************************************
 * Determine number of entries in associative array.
 */
extern (C) size_t _aaLen(AA aa)
/+    in
    {
	//printf("_aaLen()+\n");
	//_aaInv(aa);
    }
    out (result)
    {
	size_t len = 0;

	void _aaLen_x(aaA* ex)
	{
	    auto e = ex;
	    len++;

	    while (1)
	    {
		if (e.right)
		    _aaLen_x(e.right);
		e = e.left;
		if (!e)
		    break;
		len++;
	    }
	}

	if (aa.a)
	{
	    foreach (e; aa.a.b)
	    {
		if (e)
		    _aaLen_x(e);
	    }
	}
//	assert(len == result);

	//printf("_aaLen()-\n");
    }
    body+/
    {
	return aa.a ? aa.a.nodes : 0;
    }


/*************************************************
 * Get pointer to value in associative array indexed by key.
 * Add entry for key if it is not already there.
 */

extern (C) void *_aaGetp(AA* aa, TypeInfo keyti, size_t valuesize, void *pkey)
/+    in
    {
//	assert(aa);
    }
    out (result)
    {
/+	assert(result);
	assert(aa.a);
	assert(aa.a.b.length);
+/	//assert(_aaInAh(*aa.a, key));
    }
    body+/
    {
	size_t i;
	aaA* e;
	auto keysize = aligntsize(keyti.sizeof);

	if (!aa.a)
	    aa.a = new BB();

	if (!aa.a.b.length)
	{
	    alias aaA *pa;
	    auto len = prime_list[0];

	    aa.a.b = new pa[len];
	}

	auto key_hash = cast(int)pkey;
	//printf("hash = %d\n", key_hash);
	i = key_hash % aa.a.b.length;
	auto pe = &aa.a.b[i];
	while ((e = *pe) != null)
	{
	    if (key_hash == e.hash)
	    {
		auto c = (pkey > e + 1);
		if (c == 0)
		    goto Lret;
		pe = (c < 0) ? &e.left : &e.right;
	    }
	    else
		pe = (key_hash < e.hash) ? &e.left : &e.right;
	}

	// Not found, create new elem
	//printf("create new one\n");
	e = cast(aaA *) cast(void*) new void[aaA.sizeof + keysize + valuesize];
	memcpy(e + 1, pkey, keysize);
	e.hash = key_hash;
	*pe = e;

	auto nodes = ++aa.a.nodes;
	//printf("length = %d, nodes = %d\n", (*aa.a).length, nodes);
	if (nodes > aa.a.b.length * 4)
	{
	    _aaRehash(aa,keyti);
	}

    Lret:
	return cast(void *)(e + 1) + keysize;
    }


/*************************************************
 * Get pointer to value in associative array indexed by key.
 * Returns null if it is not already there.
 */

extern (C) void *_aaGetRvaluep(AA aa, TypeInfo keyti, size_t valuesize, void *pkey)
    {
	if (!aa.a)
	    return null;

	auto keysize = aligntsize(keyti.sizeof);
	auto len = aa.a.b.length;

	if (len)
	{
	    auto key_hash = cast(int)pkey;
	    //printf("hash = %d\n", key_hash);
	    size_t i = key_hash % len;
	    auto e = aa.a.b[i];
	    while (e != null)
	    {
		if (key_hash == e.hash)
		{
		    auto c = (pkey > e + 1);
		    if (c == 0)
			return cast(void *)(e + 1) + keysize;
		    e = (c < 0) ? e.left : e.right;
		}
		else
		    e = (key_hash < e.hash) ? e.left : e.right;
	    }
	}
	return null;	// not found, caller will throw exception
    }


/*************************************************
 * Determine if key is in aa.
 * Returns:
 *	null	not in aa
 *	!=null	in aa, return pointer to value
 */

extern (C) void* _aaInp(AA aa, TypeInfo keyti, void *pkey)
/+    in
    {
    }
    out (result)
    {
	//assert(result == 0 || result == 1);
    }
    body+/
    {
	if (aa.a)
	{

	    //printf("_aaIn(), .length = %d, .ptr = %x\n", aa.a.length, cast(uint)aa.a.ptr);
	    auto len = aa.a.b.length;

	    if (len)
	    {
		auto key_hash = cast(int)pkey;
		//printf("hash = %d\n", key_hash);
		size_t i = key_hash % len;
		auto e = aa.a.b[i];
		while (e != null)
		{
		    if (key_hash == e.hash)
		    {
			auto c = (pkey > e + 1);
			if (c == 0)
			    return cast(void *)(e + 1) + aligntsize(keyti.sizeof);
			e = (c < 0) ? e.left : e.right;
		    }
		    else
			e = (key_hash < e.hash) ? e.left : e.right;
		}
	    }
	}

	// Not found
	return null;
    }


/*************************************************
 * Delete key entry in aa[].
 * If key is not in aa[], do nothing.
 */

extern (C) void _aaDelp(AA aa, TypeInfo keyti, void *pkey)
    {
	aaA* e;

	if (aa.a && aa.a.b.length)
	{
	    auto key_hash = cast(int) pkey;
	    //printf("hash = %d\n", key_hash);
	    size_t i = key_hash % aa.a.b.length;
	    auto pe = &aa.a.b[i];
	    while ((e = *pe) != null)	// null means not found
	    {
		if (key_hash == e.hash)
		{
		    auto c = (pkey > e + 1);
		    if (c == 0)
		    {
			if (!e.left && !e.right)
			{
			    *pe = null;
			}
			else if (e.left && !e.right)
			{
			    *pe = e.left;
			     e.left = null;
			}
			else if (!e.left && e.right)
			{
			    *pe = e.right;
			     e.right = null;
			}
			else
			{
			    *pe = e.left;
			    e.left = null;
			    do
				pe = &(*pe).right;
			    while (*pe);
			    *pe = e.right;
			    e.right = null;
			}

			aa.a.nodes--;

			// Should notify GC that e can be free'd now
			break;
		    }
		    pe = (c < 0) ? &e.left : &e.right;
		}
		else
		    pe = (key_hash < e.hash) ? &e.left : &e.right;
	    }
	}
    }


/********************************************
 * Produce array of values from aa.
 */

extern (C) Array _aaValues(AA aa, size_t keysize, size_t valuesize)
/+    in
    {
//	assert(keysize == aligntsize(keysize));
    }
    body+/
    {
	size_t resi;
	Array a;

	void _aaValues_x(aaA* e)
	{
	    do
	    {
		memcpy(a.ptr + resi * valuesize,
		       cast(byte*)e + aaA.sizeof + keysize,
		       valuesize);
		resi++;
		if (e.left)
		{   if (!e.right)
		    {	e = e.left;
			continue;
		    }
		    _aaValues_x(e.left);
		}
		e = e.right;
	    } while (e != null);
	}

	if (aa.a)
	{
	    a.length = _aaLen(aa);
	    a.ptr = (new void[a.length * valuesize]).ptr;
	    resi = 0;
	    foreach (e; aa.a.b)
	    {
		if (e)
		    _aaValues_x(e);
	    }
	    assert(resi == a.length);
	}
	return a;
    }


/********************************************
 * Rehash an array.
 */

extern (C) AA _aaRehash(AA* paa, TypeInfo keyti)
/+    in
    {
	//_aaInvAh(paa);
    }
    out (result)
    {
	//_aaInvAh(result);
    }
    body+/
    {
	BB newb;

	void _aaRehash_x(aaA* olde)
	{
	    while (1)
	    {
		auto left = olde.left;
		auto right = olde.right;
		olde.left = null;
		olde.right = null;

		aaA* e;

		//printf("rehash %p\n", olde);
		auto key_hash = olde.hash;
		size_t i = key_hash % newb.b.length;
		auto pe = &newb.b[i];
		while ((e = *pe) != null)
		{
		    //printf("\te = %p, e.left = %p, e.right = %p\n", e, e.left, e.right);
		    assert(e.left != e);
		    assert(e.right != e);
		    if (key_hash == e.hash)
		    {
			auto c = (olde + 1> e + 1);
			assert(c != 0);
			pe = (c < 0) ? &e.left : &e.right;
		    }
		    else
			pe = (key_hash < e.hash) ? &e.left : &e.right;
		}
		*pe = olde;

		if (right)
		{
		    if (!left)
		    {	olde = right;
			continue;
		    }
		    _aaRehash_x(right);
		}
		if (!left)
		    break;
		olde = left;
	    }
	}

	//printf("Rehash\n");
	if (paa.a)
	{
	    auto aa = paa.a;
	    auto len = _aaLen(*paa);
	    if (len)
	    {   size_t i;

		for (i = 0; i < prime_list.length - 1; i++)
		{
		    if (len <= prime_list[i])
			break;
		}
		len = prime_list[i];
		newb.b = new aaA*[len];

		foreach (e; aa.b)
		{
		    if (e)
			_aaRehash_x(e);
		}

		newb.nodes = aa.nodes;
	    }

	    *paa.a = newb;
	}
	return *paa;
    }


/********************************************
 * Produce array of N byte keys from aa.
 */

extern (C) Array _aaKeys(AA aa, size_t keysize)
    {
	byte[] res;
	size_t resi;

	void _aaKeys_x(aaA* e)
	{
	    do
	    {
		memcpy(&res[resi * keysize], cast(byte*)(e + 1), keysize);
		resi++;
		if (e.left)
		{   if (!e.right)
		    {	e = e.left;
			continue;
		    }
		    _aaKeys_x(e.left);
		}
		e = e.right;
	    } while (e != null);
	}

	Array a;
	auto len = _aaLen(aa);
	if (!len)
	    return a;
	res = cast(byte[])new void[len * keysize];
	resi = 0;
	foreach (e; aa.a.b)
	{
	    if (e)
		_aaKeys_x(e);
	}
	assert(resi == len);

	a.length = len;
	a.ptr = res.ptr;
	return a;
    }


/**********************************************
 * 'apply' for associative arrays - to support foreach
 */

// dg is D, but _aaApply() is C
extern (D) typedef int delegate(void *) dg_t;

extern (C) int _aaApply(AA aa, size_t keysize, dg_t dg)
/+in
{
//    assert(aligntsize(keysize) == keysize);
}
body+/
{   int result;

    //printf("_aaApply(aa = x%llx, keysize = %d, dg = x%llx)\n", aa.a, keysize, dg);

    int treewalker(aaA* e)
    {	int result;

	do
	{
	    //printf("treewalker(e = %p, dg = x%llx)\n", e, dg);
	    result = dg(cast(void *)(e + 1) + keysize);
	    if (result)
		break;
	    if (e.right)
	    {	if (!e.left)
		{
		    e = e.right;
		    continue;
		}
		result = treewalker(e.right);
		if (result)
		    break;
	    }
	    e = e.left;
	} while (e);

	return result;
    }

    if (aa.a)
    {
	foreach (e; aa.a.b)
	{
	    if (e)
	    {
		result = treewalker(e);
		if (result)
		    break;
	    }
	}
    }
    return result;
}

// dg is D, but _aaApply2() is C
extern (D) typedef int delegate(void *, void *) dg2_t;

extern (C) int _aaApply2(AA aa, size_t keysize, dg2_t dg)
/+in
{
//    assert(aligntsize(keysize) == keysize);
}
body+/
{   int result;

    //printf("_aaApply(aa = x%llx, keysize = %d, dg = x%llx)\n", aa.a, keysize, dg);

    int treewalker(aaA* e)
    {	int result;

	do
	{
	    //printf("treewalker(e = %p, dg = x%llx)\n", e, dg);
	    result = dg(cast(void *)(e + 1), cast(void *)(e + 1) + keysize);
	    if (result)
		break;
	    if (e.right)
	    {	if (!e.left)
		{
		    e = e.right;
		    continue;
		}
		result = treewalker(e.right);
		if (result)
		    break;
	    }
	    e = e.left;
	} while (e);

	return result;
    }

    if (aa.a)
    {
	foreach (e; aa.a.b)
	{
	    if (e)
	    {
		result = treewalker(e);
		if (result)
		    break;
	    }
	}
    }
    return result;
}

