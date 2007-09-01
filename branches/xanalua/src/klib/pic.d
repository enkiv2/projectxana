/+	pic
 +	(c) 2007 Alexander Panek
 +	Licensed under the ZLIB license
 +	Part of Project XANA
 +/
module pic;

private import ports;

public enum IRQs {
	IRQ0 = 0x20,
	IRQ1,
	IRQ2,
	IRQ3,
	IRQ4,
	IRQ5,
	IRQ6,
	IRQ7,
	IRQ8,
	IRQ9,
	IRQ10,
	IRQ11,
	IRQ12,
	IRQ13,
	IRQ14,
	IRQ15
}

public void remap ( uint start ) {
	ports.outb( 0x20, 0x11 );	
	ports.outb( 0xA0, 0x11 );
	ports.outb( 0x21, cast(ubyte)start );
//	ports.outb( 0xA1, cast(ubyte)(start + 8) );
	ports.outb( 0x21, 0x04 );
//	ports.outb( 0xA1, 0x02 );
	ports.outb( 0x21, 0x01 );
	ports.outb( 0xA0, 0x11 );
	ports.outb( 0xA1, cast(ubyte)(start + 8) );
	ports.outb( 0xA1, 0x02 );
	ports.outb( 0xA1, 0x01 );
//	ports.outb( 0x21, 0x0 );
//	ports.outb( 0xA1, 0x0 );
	disableAll( ); // mask all IRQs
}

public void EOI( )
{
//	ports.outb( 0x20, 0x20 );
//	ports.outb( 0xA0, 0x20 ); // only if > 47
	ports.outb( 0x20, 0x20 );
}

public void disableAll ( ) {
	ports.outb( 0x21, 0xFF );
}

public void enable ( uint n ) {
	ubyte b;

	if ( n > IRQs.IRQ7 ) { b = inb( 0xA1 ); }
	else { b = ports.inb( 0x21 ); }

	b &= ~(1 << n);

	if ( n > IRQs.IRQ7 ) { ports.outb( 0xA1, b ); }
	else { ports.outb( 0x21, b ); }
}

public void disable ( uint n ) {
	ubyte b;

	if ( n > IRQs.IRQ7 ) { b = inb( 0xA1 ); }
	else { b = ports.inb( 0x21 ); }

	b |= ~(1 << n);

	if ( n > IRQs.IRQ7 ) { ports.outb( 0xA1, b ); }
	else { ports.outb( 0x21, b ); }
}
