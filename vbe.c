#include <real.h>
#include <stdint.h>
#include <textmode.h>
#include <vbe.h>

int vbe_controller_get_info(struct vbe_info_structure* vbe_info)
{
    struct rm_regs r = { 0 };

    r.eax = 0x4f00;
    r.es = RM_SEG(vbe_info);
    r.edi = RM_OFF(vbe_info);

    rm_int(0x10, &r, &r);

    if ((r.eax & 0x00ff) != 0x4f) {
        return -1;
    }

    return 0;
}

int vbe_get_mode_info(int mode_no, struct vbe_mode_info_structure* vbe_mode_info)
{
    struct rm_regs r = { 0 };

    r.eax = 0x4f01;
    r.ecx = mode_no;
    r.es = (uint32_t)vbe_mode_info;
    r.edi = 0;

    rm_int(0x10, &r, &r);

    if ((r.eax & 0x00ff) != 0x4f) {
        return -1;
    }

    return 0;
}
