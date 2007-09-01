module kernel_assert;

extern (C) void kernel_assert(int, char*, char*);
/+
void kernel_assert(int t, char[] f, char[] l) {
	kernel_assert(t, &f[0], &l[0]);
}+/
