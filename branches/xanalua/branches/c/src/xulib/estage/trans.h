#ifndef TRANS_H
#define TRANS_H

#include "enfilade.h"

typedef struct XuSpan_t {
	Enfilade start;
	Enfilade end;
	unsigned long vstart;
	unsigned long vend;
} XuSpan;

typedef struct XuLink_t {
	XuSpan back;
	XuSpan forward;
	XuSpan threespan;
} XuLink;

typedef struct XuClude_t {
	XuSpan back;
	XuSpan threespan;
	Enfilade forward;
	unsigned long vforward;
}

#endif
