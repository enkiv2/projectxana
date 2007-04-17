/+	kmain
 +	(c) 2007 Alexander Panek
 +	Licensed under the ZLIB license
 +	Part of Project XANA
 +/
private import Multiboot;

private import std.stdio;
private import Stdout;

private import Memory;
private import idt;
private import pic;

private import gc;

private import kernel_assert;

static idt.IDT Idt;

extern(C) static void IRQ1 ( ) {
	asm { naked; }

	writeln( "KEYBOARD INTERRUPT! AAAH!" );

	pic.EOI( );

	asm { iret; }
}

extern (C) void kmain ( MultibootInfo multiboot, uint magic ) {
//	kernel_assert.kernel_assert(0!=0, "Got to kmain\0", "30\0");
	Multiboot.theMultiboot=multiboot;
//	kernel_assert.kernel_assert(0!=0, "Multiboot set\0", "34\0");
//	gc.gc = new gc.XuGC(); 
//	init();
//	kernel_assert.kernel_assert(0!=0, "GC instantiated\0", "37\0");
	gc.gc.gc_init();
//	kernel_assert.kernel_assert(0!=0, "GC inited\0", "36\0");
	initStdout( Color.Lightgrey, Color.Lightblue );
//	kernel_assert.kernel_assert(0!=0, "kmain.d\0", "38\0");

	// initialize IDT
	Idt( );
	Idt.set(IRQs.IRQ1, &IRQ1);
	Idt.refresh( );

	// Stay protected!
	asm { sti; }
//	kernel_assert.kernel_assert(0!=0, "kmain.d\0", "47\0");
	writeln("Hello world!");
//	kernel_assert.kernel_assert(0!=0, "kmain.d", "52");
	while (1) {writeln("Looping");} 
	// normally, we'd go back to the calling function here, but that wouldn't be
	// so safe, actually. So we *explicitely loop up to infinity here
	// (theoretically).
}
