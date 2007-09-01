module std.c.stdio;

import std.stdio;

alias writef printf;

private extern(C) void puts(char* s) {
	char[] s2=*(cast(char[]*)s);
	s2=s2[0 .. std.string.find(s2, '\0')];
	std.stdio.puts(s2);
}
