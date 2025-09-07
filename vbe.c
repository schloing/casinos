#include <real.h>
#include <stdint.h>
#include <textmode.h>
#include <vbe.h>

int vbe_controller_get_info(struct vbe_info_structure* vbe_info)
{
    struct rm_regs r = { 0 };
    r.eax = 0x4f00;
    r.edi = (uint32_t)vbe_info;
    rm_int(0x10, &r, &r);

    printl(vbe_info->signature);

    if ((r.eax & 0x00ff) != 0x4f) {
        return -1;
    }

    return 0;
//  if (vbe_info->
}
