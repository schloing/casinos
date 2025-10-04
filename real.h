#ifndef REAL_H
#define REAL_H

#include <stdint.h>

struct rm_regs {
    uint16_t gs;
    uint16_t fs;
    uint16_t es;
    uint16_t ds;
    uint32_t eflags;
    uint32_t ebp;
    uint32_t edi;
    uint32_t esi;
    uint32_t edx;
    uint32_t ecx;
    uint32_t ebx;
    uint32_t eax;
} __attribute__((packed));

void rm_int(uint8_t int_no, struct rm_regs* in_regs, struct rm_regs* out_regs);

#define RM_SEG(x) ((uint16_t)((uint32_t)x >> 4))
#define RM_OFF(x) ((uint16_t)((uint32_t)x & 0x0f))

#define RM_FAR_SEG(x) ((uint16_t)((uint32_t)x >> 16))
#define RM_FAR_OFF(x) ((uint16_t)((uint32_t)x & 0xffff))

#define RM_FAR_TO_PHYS(x) (((uint32_t)RM_FAR_SEG(x) << 4) + (uint32_t)RM_FAR_OFF(x))

#endif
