#ifndef STDINT_H
#define STDINT_H

#define NULL ((void*)0) // FIXME: not supposed to be here

typedef signed char        int8_t;
typedef unsigned char      uint8_t;
typedef short              int16_t;
typedef unsigned short     uint16_t;
typedef int                int32_t;
typedef unsigned int       uint32_t;
typedef long long          int64_t;
typedef unsigned long long uint64_t;
typedef uint32_t           uintptr_t;
typedef uint64_t           intmax_t ;

#endif
