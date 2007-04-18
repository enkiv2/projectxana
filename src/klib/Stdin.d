/+	Stdin
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
module Stdin;

private import Port;
private import Memory;
private import idt;
private import pic;
private import std.stdio;
private import gc;
private import kernel_assert;

char[] SCAN_SET_1 = [
	1: '\x1b', 
	'1', 
	'2',
	'3',
	'4',
	'5',
	'6',
	'7',
	'8',
	'9',
	'0',
	'-',
	'=',
	'\b',
	'\t',
	'q',
	'w',
	'e',
	'r',
	't',
	'y',
	'u',
	'i',
	'o',
	'p',
	'[',
	']',
	'\n', 
	'\0',
	'a',
	's', 
	'd', 
	'f',
	'g', 
	'h',
	'j', 
	'k', 
	'l', 
	';', 
	'\'', 
	'`', 
	'\0',
	'\\', 
	'z', 
	'x', 
	'c', 
	'v', 
	'b', 
	'n', 
	'm', 
	',', 
	'.', 
	'/', 
	'\0',
	'\0', 
	'\0', 
	' '];
char[] SCAN_SET_1_SHIFT = [
	2: '!',
	'@',
	'#', 
	'$', 
	'%', 
	'^', 
	'&', 
	'*', 
	'(', 
	')',
	'_', 
	'+',
	'\0',
	'\0',
	'Q', 
	'W', 
	'E', 
	'R', 
	'T', 
	'Y', 
	'U', 
	'I', 
	'O', 
	'P', 
	'{', 
	'}',
	'\0',
	'\0',
	'A', 
	'S', 
	'D', 
	'F', 
	'G', 
	'H', 
	'J', 
	'K', 
	'L', 
	':', 
	'"', 
	'~',
	'\0',
	'|', 
	'Z', 
	'X', 
	'C', 
	'V', 
	'B', 
	'N', 
	'M', 
	'<', 
	'>', 
	'?'
];
/+
char[int] ALPHABET = {
	1: "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "[", "\\", "]", "^"}
+/
char scan2char(ushort scan) {/+
	if (((scan & 42) == 42) || ((scan & 54) == 54)) {
		if (!(scan>>8 >= SCAN_SET_1.length+2)) { return '\0'; }
		return SCAN_SET_1[scan>>8];
	}+/
	if (scan&0x80) {
		KB_KEYMAP=0;
		scan&=0x7f;
	}
	if (scan==75) {
		KB_KEYMAP|=KB_LEFT;
	}
	if (scan==72) {
		KB_KEYMAP|=KB_UP;
	}
	if (scan==77) {
		KB_KEYMAP|=KB_RIGHT;
	}
	if (scan==80) {
		KB_KEYMAP|=KB_DOWN;
	}
	if (((scan & 42) == 42)){
		KB_KEYMAP|=KB_LSHIFT;
	}
	if (((scan & 54) == 54)) {
		KB_KEYMAP|=KB_RSHIFT;
	}
	if (KB_KEYMAP&(KB_LSHIFT|KB_RSHIFT)) {
		if ((scan&0x00ff) < (SCAN_SET_1.length+2)) { return '\0'; }
		return SCAN_SET_1_SHIFT[scan&0x00ff];
	}/+
	if ((scan & 29) == 29) {
		if (!(scan>>8 >= SCAN_SET_1.length+2)) { return '\0'; }
		int x=(cast(int)SCAN_SET_1[scan>>8])-96;
		if (x<0) {
			return '\0';
		}
		return cast(char) x;
	}+/
	if ((scan & 29) == 29) {
		KB_KEYMAP|=KB_CTRL;
	}
	if (KB_KEYMAP&KB_CTRL) {
		if ((scan&0x00ff) > (SCAN_SET_1.length+2)) { return '\0'; }
		int x=(cast(int)SCAN_SET_1[scan&0x00ff])-96;
		if (x<0) { x+=(96-64); }
		if (x<0) {
			return '\0';
		}
		return cast(char) x;
	} else {
	if ((scan & 0x00ff) > (SCAN_SET_1.length+2)) { 
		return '\0'; 
	} else 
		return SCAN_SET_1[scan & 0x00ff];
	}
}

char read_KB() {
	ubyte status=inByte(0x64);
	if (status & 0x01) {
		int scan=inByte(0x60);
		return scan2char(scan);
	}
	return '\0';
}

char[1024] KB_BUFFER;
uint KB_BUFFLEN=0;
ubyte KB_KEYMAP=0;
const static ubyte KB_LEFT=1;
const static ubyte KB_RIGHT=2;
const static ubyte KB_UP=4;
const static ubyte KB_DOWN=8;
const static ubyte KB_LSHIFT=16;
const static ubyte KB_RSHIFT=32;
const static ubyte KB_CTRL=64;
const static ubyte KB_ALT=128;

static extern (C) void IRQ1();

static extern (C) void KB_handle () {
//	kernel_assert.kernel_assert(0!=0, "Stdin.d", "173");
/+	asm { naked; }
	asm { 
		cli;
		pusha;
		pushad;
	}+/
//	ubyte[512] newstack;
//	ubyte* stack=(cast(ubyte*[])newstack)[0];
//	void* currstack;
/+	asm { 
		mov currstack,SP;
		mov SP,stack; 
	}
+/
	KB_BUFFER[++KB_BUFFLEN]=read_KB();
	putc(KB_BUFFER[KB_BUFFLEN]);
	pic.EOI();
/+	asm {
//		push EBP;
//		mov EBP,ESP;
		popad;
		popa;
//		leave;
		add ESP,12;
		iret;
	}+/
//	kernel_assert.kernel_assert(0!=0, "Stdin.d", "186");
//	asm { mov SP, currstack; }
//	asm { sti; }
//	asm { iret; }
}

char[] KB_read(int l) {
	char[] temp= KB_BUFFER[0 .. l];
	KB_BUFFER[0 .. KB_BUFFLEN - l]=KB_BUFFER[l .. KB_BUFFLEN];
	KB_BUFFLEN-=l;
/+	for (int i=l; i<KB_BUFF_LEN; i++) {
		KB_BUFFER[i]='\0';
	}
+/	return temp;
}

char KB_read() {
	char temp=KB_BUFFER[0];
	KB_BUFFER[0 .. KB_BUFFLEN-1]=KB_BUFFER[1 .. KB_BUFFLEN];
	KB_BUFFLEN-=1;
	return temp;
}

void init_KB (inout IDT i) {
	KB_BUFFLEN=0;
	i.set(IRQs.IRQ1, &IRQ1);
//	i.refresh();
}

