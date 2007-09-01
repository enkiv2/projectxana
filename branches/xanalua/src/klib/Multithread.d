module Multithread;

private import idt;
private import pic;

static extern (C) void irq0_handler() { pic.EOI(); asm{ iret; } }

void init_threading (inout IDT i) {
	i.set(IRQs.IRQ0, &irq0_handler);
}
