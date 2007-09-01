/+	idt
 +	(c) 2007 Alexander Panek
 +	License under the ZLIB license
 +	Part of Project XANA
 +/
module idt;

private import Memory;
private import pic;
private import std.stdio;
private import std.stdint;

alias void * fptr;

private struct Descriptor {
	 uint16_t offset_low = 0x0000,
		           segment_selector = 0x0000,
		           flags = 0x8e00,
		           offset_high = 0x0000;

	public void opCall ( fptr isr, ushort segment ) {
		this.set( isr, segment );
	}

	/* Check, whether the presence flag is set */
	public bool isPresent ( ) {
		return ( this.flags & cast(ushort)(1 << 15) ) > 0;
	}

	/* turns Descriptor into a dummy/null descriptor */
	public void clear ( ) {
		memcpy(cast(void*)null, cast(void *)this, this.sizeof );
	}

	/* create a descriptor! */
	public void set ( fptr isr, ushort segment ) {
		this.offset_low = cast(uint16_t)(cast(uint)isr);
		this.offset_high = cast(uint16_t)((cast(uint)isr) >> 16);
		this.segment_selector = cast(uint16_t)segment;
		this.flags |= (1 << 15); // set presence flag
	}
}

private static IDTPointer pidt;

public align(1) struct IDT {
	private Descriptor [0x7ff] descriptors;

	/* initialize IDT structure and set pointer to given base */
	public void opCall ( ) {
		/* remap the pic and mask all IRQs, so they don't start firing as we
		 * enable interrupts. */
		pic.remap( IRQs.IRQ0 );
		pic.disableAll( );

		/* turn all descriptors into dummy/null descriptors first */
		for ( uint i = 20; i < 0x7ff; i++ ) {
			this.descriptors[i].clear( );		
		}

		/* register all exceptions. Period. */
		this.registerAllExceptions( );

		/* create and load the idt pointer with lidt */
		this.refresh( );
	}

	/* set specific descriptor to function /isr/ */
	public void set ( uint i, fptr isr ) {
		this.descriptors[i]( isr, cast(ushort)0x08 );

		if ( (i > IRQs.IRQ0) && (i < IRQs.IRQ15) ) {
			pic.enable( i );
		}
	}

	/* lidt */
	public void refresh ( ) {
		pidt( this );

		asm {
			lidt pidt; // load IDTPointer into corresponding register
		}
	}

	private void registerAllExceptions( ) {
		this.descriptors[0].set( &divByNullException, cast(ushort)0x08 );
		this.descriptors[2].set( &nmiInterruptException, cast(ushort)0x08 );
		this.descriptors[3].set( &breakpointException, cast(ushort)0x08 );
		this.descriptors[4].set( &overflowException, cast(ushort)0x08 );
		this.descriptors[5].set( &boundsException, cast(ushort)0x08 );
		this.descriptors[6].set( &invalidOpcodeException, cast(ushort)0x08 );
		this.descriptors[7].set( &devNotAvailException, cast(ushort)0x08 );
		this.descriptors[8].set( &doubleFaultException, cast(ushort)0x08 );
		this.descriptors[9].set( &coProcSegOverrunException, cast(ushort)0x08 );
		this.descriptors[10].set( &invalidTSSException, cast(ushort)0x08 );
		this.descriptors[11].set( &segNotPresentException, cast(ushort)0x08 );
		this.descriptors[12].set( &stackSegFaultException, cast(ushort)0x08 );
		this.descriptors[13].set( &generalProtectionFaultException, cast(ushort)0x08 );
		this.descriptors[14].set( &pageFaultException, cast(ushort)0x08 );
		this.descriptors[16].set( &fpuErrorException, cast(ushort)0x08 );
		this.descriptors[17].set( &alignmentCheckException, cast(ushort)0x08 );
		this.descriptors[18].set( &machineCheckException, cast(ushort)0x08 );
		this.descriptors[19].set( &simdException, cast(ushort)0x08 );
	}
}

public align(1) struct IDTPointer {
	ushort limit;
	uint   base;

	public void opCall ( IDT *b ) {
		this.base = cast(uint)b;
		this.limit = 0x7ff;
	}
}

// alias klib.io.writeln writeln;

static extern(C) {
	void divByNullException ( ) {
		asm { naked; }
		writeln( "Division by Null Exception\n\n...halting." );
		for (;;) { }
	}

	void nmiInterruptException ( ) {
		asm { naked; }
		writeln( "Nonmaskable external interrupt\n\n...halting." );
		for (;;) { }
	}

	void breakpointException ( ) {
		asm { naked; }
		writeln( "Breakpoint!" );
		asm { iret; }
	}

	void overflowException ( ) {
		asm { naked; }
		writeln( "Overflow\n\n...halting." );
		for (;;) { }
	}

	void boundsException ( ) {
		asm { naked; }
		writeln( "Bound Range Exceeded\n\n...halting." );
		for (;;) { }
	}

	void invalidOpcodeException ( ) {
		asm { naked; }
		writeln( "Invalid/undefined opcode\n\n...halting." );
		for (;;) { }
	}

	void devNotAvailException ( ) {
		asm { naked; }
		writeln( "Math Coprocessor not available\n\n..halting." );
		for (;;) { }
	}

	void doubleFaultException ( ) {
		asm { naked; }
		writeln( "DOUBLE FAULT ON A PLANE! OH NOES!" );
		for (;;) { }
	}

	void coProcSegOverrunException ( ) {
		asm { naked; }
		writeln( "Coprocessor segment overrun" );
		for (;;) { }
	}

	void invalidTSSException ( ) {
		asm { naked; }
		writeln( "Invalid TSS..check your implementation ;P" );
		for (;;) { }
	}

	void segNotPresentException ( ) {
		asm { naked; }
		writeln( "Segment not present." );
		for (;;) { }
	}

	void stackSegFaultException ( ) {
		asm { naked; }
		writeln( "Stacksegment fault FOSHIZZLE!" );
		for (;;) { }
	}

	void generalProtectionFaultException ( ) {
		asm { naked; }
		writeln( "GP ON A PLANE! OH NOES!" );
		for (;;) { }
	}

	void pageFaultException ( ) {
		asm { naked; }
		writeln( "pagefault..duh." );
		for (;;) { }
	}

	void fpuErrorException ( ) {
		asm { naked; }
		writeln( "fpu" );
		for (;;) { }
	}

	void alignmentCheckException ( ) {
		asm { naked; }
		writeln( "align" );
		for (;;) { }
	}

	void machineCheckException ( ) {
		asm { naked; }
		writeln( "machine" );
		for (;;) { }
	}

	void simdException ( ) {
		asm { naked; }
		writeln( "simd" );
		for (;;) { }
	}

}
