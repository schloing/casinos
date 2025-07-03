#include "tinf.h"
#include "disk.h"

void printx(const char *s) {
    while (*s) {
        unsigned char c = *s++;
        __asm__ volatile (
            "movb $0x0e, %%ah\n\t"
            "movb %0, %%al\n\t"
            "int $0x10"
            :
            : "r"(c)
            : "ax"
        );
    }
}

void entry(uint8_t source_address, uint8_t stage2_size)
{
    #define STAGE2_DEST_ADDRESS 0x10000
    printx("decompressing stage2...\r\n");
    (void)tinf_gzip_uncompress((uint8_t*)STAGE2_DEST_ADDRESS, (void*)0, (uint8_t*)source_address, stage2_size);
    void (*stage2)() = (void(*)(void))STAGE2_DEST_ADDRESS;
    stage2();
    __builtin_unreachable();
}