/+	std.format
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
module std.format;

import std.string;
import std.stdarg;

version(stage2) {
enum Mangle : char {
	Tvoid	= 'v',
	Tbit	= 'b',
	Tbool	= 'x',
	Tbyte	= 'g',
	Tubyte	= 'h',
	Tshort	= 's',
	Tushort	= 't',
	Tint	= 'i',
	Tuint	= 'k',
	Tlong	= 'l',
	Tulong	= 'm',
	Tfloat	= 'f',
	Tdouble	= 'd',
	Treal	= 'e',

	Tifloat	= 'o',
	Tidouble= 'p',
	Tireal	= 'j',
	Tcfloat	= 'q',
	Tcdouble= 'r',
	Tcreal	= 'c',

	Tchar	= 'a',
	Twchar	= 'u', 
	Tdchar	= 'w',
	
	Tarray	= 'A',
	Tsarray	= 'G', 
	Tpointer= 'P',
	Tfunction='F',
	Tident	= 'I',
	Tclass	= 'C', 
	Tstruct	= 'S', 
	Tenum	= 'E', 
	Ttypedef= 'T', 
	Tdelegate='D',
}
}
char[] format(char[] f, TypeInfo[] args, va_list argptr, void* p_args) {
	char[] temp=f;
	foreach (TypeInfo ti; args) {
		char[] x;
		switch (ti.stringOf()) {
			case "char[]":
				x=*(cast(char[]*)p_args);
				break;
			case "char":
				x[0]=*(cast(char*)p_args);
				break;
			case "int":
				x=toString(*(cast(int*)p_args));
				break;
			case "uint":
				x=toString(*(cast(uint*)p_args));
				break;
			case "float":
				x=toString(cast(double)(*(cast(float*)p_args)));
				break;
			case "double":
				x=toString(*(cast(double*)p_args));
				break;
			case "long":
				x=toString(*(cast(long*)p_args));
				break;
			case "ulong":
				x=toString(*(cast(ulong*)p_args));
				break;
			default:
				x="";
		}
		temp=replace(temp, "%s", x, 1);
	}
	return temp;
}

