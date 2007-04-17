// Modified from the GDC distribution for Project XANA
module std.asserterror;

import gc;
import std.c.stdio;
//import std.c.stdlib;

class AssertError : Error
{
    uint linnum;
    char[] filename;

    this(char[] filename, uint linnum)
    {
	this(filename, linnum, null);
    }

    this(char[] filename, uint linnum, char[] msg)
    {
	this.linnum = linnum;
	this.filename = filename;

	char* buffer;
	size_t len;
	int count;

	/* This code is careful to not use gc allocated memory,
	 * as that may be the source of the problem.
	 * Instead, stick with C functions.
	 */

	len = 23 + filename.length + uint.sizeof * 3 + msg.length + 1;
	buffer = cast(char*)gc.gc.malloc(len);
	if (buffer == null)
	    super("AssertError no memory");
	else
	{
	    version (Win32) alias _snprintf snprintf;
	    count = 0;
	    if (count >= len || count == -1)
	    {	super("AssertError internal failure");
		gc.gc.free(buffer);
	    }
	    else
		super(buffer[0 .. count]);
	}
    }

    ~this()
    {
	if (msg.ptr && msg[12] == 'F')	// if it was allocated with malloc()
	{   gc.gc.free(msg.ptr);
	    msg = null;
	}
    }
}


/********************************************
 * Called by the compiler generated module assert function.
 * Builds an AssertError exception and throws it.
 */

extern (C) static void _d_assert(char[] filename, uint line)
{
    //printf("_d_assert(%s, %d)\n", cast(char *)filename, line);
    AssertError a = new AssertError(filename, line);
    //printf("assertion %p created\n", a);
    throw a;
}

extern (C) static void _d_assert_msg(char[] msg, char[] filename, uint line)
{
    //printf("_d_assert_msg(%s, %d)\n", cast(char *)filename, line);
    AssertError a = new AssertError(filename, line, msg);
    //printf("assertion %p created\n", a);
    throw a;
}

