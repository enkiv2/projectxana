#ifndef STRING_H
#define STRING_H
#define size_t int
#define NULL 0

size_t strlen(const char *s);
char *strchr(const char *s, int c);
char *strcpy(char *d, const char *s);
char *strncpy(char *d, const char *s, size_t n);
char *strcat(char *d, const char *s);
char *strncat(char *d, const char *s, size_t n);
int strcmp(const char *s1, const char *s2);
int strcoll(const char *s1, const char *s2);
size_t strcspn(const char *s, const char *reject);
void *memcpy(void *d, const void *s, size_t n);
int memcmp(const void *s1, const void *s2, size_t n);

int (isalpha)(int c);
int (isalnum)(int c);
int (isdigit)(int c);
int (isspace)(int c);
int (iscntrl)(int c);

#endif
