#ifndef IDT_H
#define IDT_H

#include <stdint.h>

struct idt {
    uint16_t limit;
    uint32_t addr;          // 32 bits in protected mode; 64 bits in IA-32e mode
} __attribute__((packed));

// https://wiki.osdev.org/Interrupt_Descriptor_Table
struct idt_entry {
    uint16_t offset0;
    uint16_t segment;
    uint8_t reserved;
    uint8_t attr;           // P, DPL, 0, GATE TYPE
    uint16_t offset1;
} __attribute__((packed));

#endif
