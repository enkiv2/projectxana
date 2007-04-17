module paging;

void enablePaging() {
	asm {
		naked;
		mov EAX,CR0;
		or EAX, 0x80000000;
		mov CR0,EAX;
	}
}
void disablePaging() {
	asm {
		naked;
		mov EAX, CR0;
		and EAX, 0x7fffffff;
		mov CR0, EAX;
	}
}

