extern (C) {
	double udiv(int, int, int);
	double div(int, int, int);
	double umod(int, int, int);
}

extern (C) double __udivdi3(int x, int y, int z) {
	return udiv(x, y, z);
}

extern (C) double __divdi3(int x, int y, int z) {
	return div(x, y, z);
}

extern (C) double __umoddi3(int x, int y, int z) {
	return umod(x, y, z);
}/+
extern (C) void __udivdi3() {}
extern (C) void __divdi3() {}
extern (C) void __umoddi3() {}+/
