#include "tinf.h"
#include "disk.h"

extern void entry(const uint32_t source_address, const uint32_t stage2_size);

void write_string( int colour, const char *string )
{
    volatile char *video = (volatile char*)0xB8000;
    while( *string != 0 )
    {
        *video++ = *string++;
        *video++ = colour;
    }
}

void entry(const uint32_t source_address, const uint32_t stage2_size)
{
    #define STAGE2_DEST_ADDRESS 0x8000
    write_string(3, "decompressing...");
    uint32_t dest_length = 0;
    (void)tinf_gzip_uncompress((void*)STAGE2_DEST_ADDRESS, &dest_length, (void*)source_address, (uint32_t)stage2_size);
    if (dest_length != stage2_size) {
        // TODO: handle this
    }
    void (*stage2)() = (void (*)(void))STAGE2_DEST_ADDRESS;
    stage2();
    __builtin_unreachable();
}
