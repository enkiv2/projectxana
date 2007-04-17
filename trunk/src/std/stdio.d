/+	std.stdio
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
module std.stdio;

import Stdout;
import Stdin;
import std.format;
import std.stdarg;

extern (C) int kernel_assert_strlen(char*);

void putc(char c) {
	if (Stdout.Stdout.cursor.x>=25 && Stdout.Stdout.cursor.y>=80) {
		Stdout.Stdout.scrollDown();
	}
	Stdout.Stdout.putChar(c);
//	kernel_assert_print(&c, 1, 0);
}

void puts(char[] s) {
/+	foreach (c; s) {
		putc(c);
	}+/
	for (int i=0; i<s.length; i++) {
		putc(s[i]);
	}
//	kernel_assert_print(&s[0], s.length, Stdout.Stdout.index);
//	Stdout.Stdout.index+=s.length;
}

void writef(char[] f, TypeInfo[] args, va_list argptr, void* p_args) {
	puts(format(f, args, argptr, p_args)); // non-worky, try appending and char instead ;-)
}

void writefl(char[] f, TypeInfo[] args, va_list argptr, void* p_args) {
	puts(format(f, args, argptr, p_args)~"\n");
}

void writeln(char[] f) {
	puts(f);
	puts("\n");
}

char getc() {
	return KB_read();
}

char[] read(int l) {
	return KB_read(l);
}

char[] gets(char delim=' ') {
	char[] buf;
	char temp;
	temp=getc();
	while (temp!=delim) {
		if (temp=='\x03' || temp=='\x04') {
			buf=buf[0 .. 0];
			buf[0]=temp;
			return buf;
		}
		buf~=temp;
		temp=getc();
	}
	return buf;
}

char[] getln() {
	return gets('\n');
}

