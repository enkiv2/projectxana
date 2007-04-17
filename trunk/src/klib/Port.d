/+	Port
 +	(c) 2007 Alexander Panek
 +	Licensed under the ZLIB license
 +	Part of Project XANA
 +/
module Port;

ubyte inByte (ushort port) {
	ubyte value;
	inByte(port, value);
	return value;
}

ushort inWord (ushort port) {
	short value;
	inWord(port, value);
	return value;
}

void inWord (in ushort port, out short value ) {
	ushort temp;

	asm {
		push DX;
		push AX;
		mov DX, port;
		in AX, DX;
//		mov AH, AL;
//		add DX, 1;
//		in AL, DX;
		mov temp, AX;
		pop AX;
		pop DX;
	}
	value=temp;
}

void inByte ( in ushort port, out ubyte value ) {
	ushort temp;

	asm {
		push DX;
		push AX;
		mov DX, port;
		in AL, DX;
		mov temp, AL;
		pop AX;
		pop DX;
	}

	value = temp & 0x00FF;
}

void outByte ( in ushort port, in ubyte value ) {
	ushort foo = value;

	asm {
		push DX;
		push AX;
		mov DX, port;
		mov AL, value;

		out DX, AL;
		pop AX;
		pop DX;
	}
}

void outWord (in ushort port, in ushort value) {
	ushort foo=value;

	asm {
		push DX;
		push AX;
		mov DX, port;
		mov AX, value;

		out DX, AX;
//		inc DX;
//		mov AL, AH;
		pop AX;
		pop DX;
	}
}
