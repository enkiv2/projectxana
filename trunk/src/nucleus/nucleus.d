/+	nucleus.d
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
private import Multiboot;

private import std.stdio;
private import Stdout;

private import gc;

private import Memory;
private import idt;
private import pic;
private import Stdin;
private import Multithread;

private import unreal; // for flat memory

private import paging;

private import logo;
private import aileta;

private import Graphics;
private import gstage.logo_gfx;

static idt.IDT Idt;

extern (C) void kmain ( MultibootInfo multiboot, uint magic ) {
	initStdout( Color.Black, Color.Lightgrey );
	gc.gc.gc_init();	
	writeln("Booting NUCLEUS...");
//	puts("\tStarting unreal mode...");
//	unreal.setUnreal();
//	writeln("\t[OK]");
//	puts("\tTurning off paging...");
	paging.disablePaging();
//	writeln("\t[OK]");
//	puts("\tInitializing IDT...");
	
	// initialize IDT
	Idt( );
//	puts("\n\t\tStarting KB handling");
	Multithread.init_threading(Idt);
	Stdin.init_KB(Idt);
//	pic.remap(IRQs.IRQ0);
//	puts("\n\t\tRefreshing...");
	Idt.refresh();
//	writeln("\t[OK]");
//	puts("Starting interrupts...");
	// Stay protected!
	asm { sti; }
//	writeln("\t[OK]");
	Stdout.Stdout.clearScreen();
	writeln(logo.LOGO);
	writeln("Welcome to Project XANA");

//	for (int i=0; i<10000; i++) {}
//	Graphics.setGraphicsMode(12);
//	gstage.logo_gfx.logo_init_rle();
//	gstage.logo_gfx.LOGO_RLE.draw(0, 0, 0);
//	gstage.logo_gfx.logo_init();
//	gstage.logo_gfx.LOGO.draw(0, 0, 0);
	puts("Press any key to start the AILETA interface");
	while(getc()=='\0') { asm{hlt;} }
	puts("Generating NODE info...");
	aileta.init_node();
//	writeln("\t[OK]");
	puts("Starting AILETA...");
	aileta.init();
//	puts("\nHalting.");
	for ( ;; ) {} 
	// normally, we'd go back to the calling function here, but that wouldn't be
	// so safe, actually. So we *explicitely loop up to infinity here
	// (theoretically).
}
