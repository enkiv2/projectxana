module kernel_assert;
private import Stdout;
//import std.stdio;
//extern (C) void kernel_assert(int, char*, char*);

private void kputs(char[] s) {
	for (int i=0; i<s.length; i++) {
		Stdout.Stdout.putChar(s[i]);
	}
}

void kernel_assert(int t, char[] f, char[] l) {
//	kernel_assert(t, &f[0], &l[0]);
	Stdout.Stdout.clearScreen();
	kputs("XANA: assert: ");
	kputs(f);
	kputs(":");
	kputs("\n");
	kputs(l);
	kputs("\n\nFAILED.");
}
