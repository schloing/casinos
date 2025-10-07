#include <real.h>
#include <stdint.h>
#include <vga.h>

uint8_t* font_map = 0;

uint8_t* vga_get_font_addr()
{
    struct rm_regs r = { 0 };

    r.eax = 0x1130;
    r.ebx = 0x0100; // mov bh, 1
    
    rm_int(0x10, &r, &r);

    return (uint8_t*)RM_SEG_OFF_TO_PHYS(r.es, r.ebp);
}
