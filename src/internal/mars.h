
/*
 * Placed into the Public Domain
 * written by Walter Bright, Digital Mars
 * www.digitalmars.com
 */

//#include <stddef.h>

#if __cplusplus
extern "C" {
#endif

typedef int size_t;

struct ClassInfo;
struct Vtbl;

typedef struct Vtbl
{
    size_t len;
    void **vptr;
} Vtbl;

typedef struct Interface
{
    struct ClassInfo *classinfo;
    struct Vtbl vtbl;
    int offset;
} Interface;

typedef struct Object
{
    void **vptr;
    void *monitor;
} Object;

typedef struct ClassInfo
{
    Object object;

    size_t initlen;
    void *init;

    size_t namelen;
    char *name;

    Vtbl vtbl;

    size_t interfacelen;
    Interface *interfaces;

    struct ClassInfo *baseClass;

    void *destructor;
    void *invariant;

    int flags;
} ClassInfo;

typedef struct Exception
{
    Object object;

    size_t msglen;
    char *msg;
} Exception;

typedef struct Array
{
    size_t length;
    void *ptr;
} Array;

struct Delegate
{
    void *thisptr;
    void (*funcptr)();
};

void _d_monitorenter(Object *h);
void _d_monitorexit(Object *h);
void _d_monitorrelease(Object *h);

int _d_isbaseof(ClassInfo *b, ClassInfo *c);
Object *_d_dynamic_cast(Object *o, ClassInfo *ci);

Object * _d_newclass(ClassInfo *ci);
void _d_delclass(Object **p);

void _d_OutOfMemory();

#if __cplusplus
}
#endif

