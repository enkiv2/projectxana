/*
 *libbc.c
 * functions from the standard C library that are needed by the Lua core
 */

#include <string.h>

size_t strlen(const char *s)
{
 size_t n=0;
 while (*s++) n++;
  return n;
}

char *strchr(const char *s, int c)
{
 while (*s!=c && *s!=0) s++;
 return (*s==c) ? (char*)s : NULL;
}

char *strcpy(char *d, const char *s)
{
 char *t=d;
 while ((*t++=*s++)) ;
 return d;
}
char *strncpy(char *d, const char *s, size_t n)
{
 char *t=d;
 while (n-- && (*t++=*s++)) ;
  return d;
}

char *strcat(char *d, const char *s)
{
 return strcpy(d+strlen(d),s);
}

char *strncat(char *d, const char *s, size_t n)
{
 return strncpy(d+strlen(d),s,n);
}

int strcmp(const char *s1, const char *s2)
{
 while (*s1==*s2 && *s1!=0 && *s2!=0) s1++,s2++;
 return *s1-*s2;
}

int strcoll(const char *s1, const char *s2)
{
 return strcmp(s1,s2);
}

size_t strcspn(const char *s, const char *reject)
{
 size_t n=0;
 for (n=0; *s; n++,s++)
 {
  const char *r;
  for (r=reject; *r; r++) if (*r==*s) return n;
 }
 return n;
}
/*
void *memcpy(void *d, const void *s, size_t n)
{
 char *a=d;
 const char *b=s;
 while (n--) *a++=*b++;
 return d;
}

int memcmp(const void *s1, const void *s2, size_t n)
{
 const unsigned char *a=s1;
 const unsigned char *b=s2;
 if (n==0) return 0;
 while (--n && *a==*b) a++,b++;
 return *a-*b;
}
*/
//#include <ctype.h>

int (isalpha)(int c)
{
 return (c>='A' && c<='Z') || (c>='a' && c<='z');
}

int (isalnum)(int c)
{
 return (c>='A' && c<='Z') || (c>='a' && c<='z') || (c>='0' && c<='9');
}

int (isdigit)(int c)
{
 return (c>='0' && c<='9');
}

int (isspace)(int c)
{
 return (c==' ' || c=='\t' || c=='\n' || c=='\r' || c=='\f' || c=='\v');
}

int (iscntrl)(int c)
{
 return (c>=0 && c<' ') || c==127;
}



				       
