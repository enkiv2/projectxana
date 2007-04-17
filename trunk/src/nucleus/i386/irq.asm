global IRQ1;
extern KB_handle;

IRQ1:
	pushad;
	call KB_handle;
	popad;
	iret;

