#ifndef __lstage_h_inc__
#define __lstage_h_inc__

#include "../kernel_assert.h"

#define NULL (void *) 0
#define EXIT_FAILURE (-1)
#define EXIT_SUCCESS (0)

typedef unsigned long size_t;
typedef signed long ptrdiff_t;


void *malloc(size_t);
void *realloc(void *, size_t);
void free(void *);


/*** stdarg.h ***/
typedef __builtin_va_list va_list;

#define va_start(x, y) __builtin_va_start(x, y)
#define va_end(x) __builtin_va_end(x)
#define va_arg(x, y) __builtin_va_arg(x, y)
/*** end stdarg.h ***/


/*** limits.h ***/
#define INT_MAX (2147483647)
/*** end limits.h ***/


/*** math.h ***/
#define abs(x) __builtin_abs(x)
#define floor(x) __builtin_floor(x)
#define pow(x, y) __builtin_pow(x, y)
/*** end math.h ***/


/*** stdlib.h ***/
#define exit(x) kernel_assert(0, "lstage.h", "39")
/*** end stdlib.h ***/

#define strlen(x) ( { \
	register size_t i; \
	for (i = 0; (x)[i] != 0; ++i); \
	i; \
} )

#endif

