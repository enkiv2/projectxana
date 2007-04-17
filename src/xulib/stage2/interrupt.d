import idt;
import pic;
import node;
import enfilade;
import cell;
import enfs;

static idt.IDT Idt;

template ISR (alias n, alias e, alias name) {
	extern (C)void name () {
		asm { naked; }
		EPL.interpCell(n, e);
		pic.EOI();
		asm{iret;}
	}
}

void set_idt(Enfs n, Enfilade e, uint irq) {
	extern (C) void delegate() *temp;
	mixin ISR!(n, e, temp);
	Idt.set(irq, temp);
}
