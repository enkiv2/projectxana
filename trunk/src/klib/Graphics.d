module Graphics;

alias bool bit;

private import gc;
private import ports;
private import std.memory;

uint VIDEO_ADDR=0xA0000;
ubyte* VIDEO_BUFFER;

uint HEIGHT=480;

uint GRAPHICS_ADDR_PORT=0x3ce;
uint GRAPHICS_DATA_PORT=0x3cf;

enum GRAPHICS_REGS : uint {
	SET_RESET = 0,
	ENABLE_SET_RESET,
	COLOR_COMPARE,
	DATA_ROTATE,
	READ_MAP_SELECT,
	GRAPHICS_MODE,
	MISC,
	COLOR_DONT_CARE,
	BIT_MASK
};

void setGraphicsMode (int mode) {
	outb(GRAPHICS_ADDR_PORT, cast(ubyte)GRAPHICS_REGS.MISC);
	outb(GRAPHICS_DATA_PORT, 0x80);
	HEIGHT=480;
	VIDEO_BUFFER=cast(ubyte*) VIDEO_ADDR;
}

void setTextMode () {
	outb(GRAPHICS_ADDR_PORT, cast(ubyte)GRAPHICS_REGS.MISC);
	outb(GRAPHICS_DATA_PORT, 0x00);
}
	

struct Bitmap {
	bit[][] data;
	void draw(int x, int y, ubyte color) {
		for (int i=0; i<data.length; i++) {
			for (int j=0; j<data[i].length; j++) {
				if (data[i][j]) {
					(*(VIDEO_BUFFER+(((i+x)*HEIGHT)+(j+y))))=color;
				}
			}
		}
	}
}

struct RLEBitmap {
	uint[][] data;
	bit start;
	void draw(int x, int y, ubyte color) {
		bit curr=start;
		for (int i=0; i<data.length; i++) {
			int i2=0;
			for (int j=0; j<data[i].length; j++) {
				if (data[i][j]) {
					if (curr) {
						memset.memset(cast(void*)((VIDEO_BUFFER+(((i+x)*HEIGHT)+(i2+y)))), cast(int)color, data[i][j]);
					}
					i2+=data[i][j];
				}
				curr=!curr;
			}
		}
	}
}

struct Pixmap {
	ubyte[][] data;
	void draw(int x, int y) {
		for (int i=0; i<data.length; i++) {
			for (int j=0; j<data[i].length; j++) {
				(*(VIDEO_BUFFER+(((i+x)*HEIGHT)+(j+y))))=data[i][j];
			}
		}
	}
}

struct RLEEntry {
	ubyte color;
	uint length;
}

struct RLEPixmap {
	RLEEntry[][] data;
	void draw(int x, int y) {
		for (int i=0; i<data.length; i++) {
			int i2=0;
			for (int j=0; j<data[i].length; j++) {
				memset.memset(cast(void*)((VIDEO_BUFFER+(((i+x)*HEIGHT)+(i2+y)))), cast(int)data[i][j].color, data[i][j].length);
				i2+=data[i][j].length;
			}
		}
	}
}

