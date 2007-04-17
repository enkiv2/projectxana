/+	Stdout
 +	(c) 2007 Alexander Panek
 +	Licensed under the ZLIB license
 +	Part of Project XANA
 +/
module Stdout;

private import Port;
private import Memory;

extern (C) void kernel_assert_clear();
extern (C) void kernel_assert_print(char*, int, int);

public enum Color : ubyte {
	Black = 0,
	Blue,
	Green,
	Cyan,
	Red,
	Magenta,
	Brown,
	Lightgrey,
	Darkgrey,
	Lightblue,
	Lightgreen,
	Lightcyan,
	Lightred,
	Lightmagenta,
	Yellow,
	White           // = 0x0f
}
/+
extern(C) void _D10TypeInfo_h6__initZ ( ) { }
+/
struct Position {
	uint x,
		 y;

	public static Position opCall ( uint x, uint y ) {
		Position p;

		p.x = x;
		p.y = y;

		return p;
	}
}

struct Character {
	char  character;
	ubyte attribute;

	public static Character opCall ( char c, ubyte a ) {
		Character ch;

		ch.character = c;
		ch.attribute = a;

		return ch;
	}
}

struct Term {
	uint        index;
	Position    cursor;
	Character * buffer;
	Color       foreground;
	Color       background;

	private Position size = { x:80, y:25 };

	public void setColor ( Color fg, Color bg ) {
		this.foreground = fg;
		this.background = bg;
	}

	public void moveHWCursor ( uint x, uint y ) {
		this.moveHWCursor( Position( x, y ) );	
	}

	public void moveHWCursor ( Position p ) {
		uint *CRTCAddr = cast(uint *)0x3d4;
		uint offset = p.x + p.y * 80;

		outByte( cast(ushort)CRTCAddr, cast(ubyte)14 );
		outByte( cast(ushort)CRTCAddr + 1, cast(ubyte)(offset >> 8) );
		outByte( cast(ushort)CRTCAddr, cast(ubyte)15 );
		outByte( cast(ushort)CRTCAddr + 1, cast(ubyte)offset );
	}

	public void clearScreen ( ) {
		this.gotoPosition(0, 0);
		for (int i=0; i<size.x*size.y; i++) {
			this.putChar(' ');
		}
		this.gotoPosition(0, 0);

//		kernel_assert_clear();
	}

	public void putChar ( char c ) {
		if ( c == '\n' || c == '\r' ) {
			this.newLine;
		}

		ubyte attribute = ((this.foreground & 0x0f) | ((this.background << 4) & 0xf0));

//		this.buffer[index++] = Character( c, attribute );+/
		if (c=='\n') {
			this.newLine();
		} else if (c=='\t') {
			this.cursor.x+=8;
		} else {
//			kernel_assert_print(&c, 1, cast(int)(index++));
			this.buffer[index++] = Character (c, attribute);
			this.cursor.x++;
		}
		if ( this.cursor.x >= this.size.x ) {
			this.newLine;
		}
		
		this.gotoPosition( cursor.x, cursor.y );
//		kernel_assert_print(&c, 1, cast(int)(cursor.x*cursor.y));
	}

/+	public void putString ( char [] s ) {
		foreach ( c; s ) {
			this.putChar( c );
		}
	}

	public void putFString ( char [] format, ... ) {
		uint a = 0;
		char c;

		for( uint i = 0; i < format.length; c = format[i++] ) {
			if ( c != '%' ) {
				this.putChar( format[i] );
			}

			c = format[i++];

			switch ( c ) {
				case 'd':
				case 'u':
				case 'b':
				case 'x':
			}
		}
	}
+/

	public void gotoPosition ( uint x, uint y ) {
		this.gotoPosition( Position( x, y ) );
	}

	public bool gotoPosition ( Position p ) {
		if ( (p.x >= 0 && p.x < this.size.x) && (p.y >= 0 && p.y < this.size.y) ) {
			this.cursor.x = p.x;
			this.cursor.y = p.y;

			this.index = (this.size.x * this.cursor.y) + this.cursor.x;
			this.moveHWCursor( this.cursor.x, this.cursor.y );

			return true;
		} else {
			return false;
		}
	}

	public void newLine ( ) {
		this.cursor.x = 0;
		this.cursor.y++;

		if ( this.cursor.y >= this.size.y ) {
			this.scrollDown( this.cursor.y - this.size.y );
		}
	}

	public void scrollDown ( uint lines = 1 ) {
		while ( lines ) {
			for ( uint i = 0; i < this.size.y-1; i++ ) {
				memcpy( cast(void *)&this.buffer[ (i-1) * this.size.x],
						cast(void *)&this.buffer[i * this.size.x],
						this.size.x 
					  );
			}
		}
//		memset( cast(void*) &this.buffer [(this.size.y-1) * this.size.x], 0, this.size.x);
	}
}

Term Stdout;

public void initStdout ( Color foreground, Color background ) {
	Stdout.cursor.x = 0;
	Stdout.cursor.y = 0;
	Stdout.index = 0;
	Stdout.buffer = cast(Character *)0xb8000;
	Stdout.setColor( foreground, background );
}

