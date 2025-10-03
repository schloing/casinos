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

int vbe_get_mode_info(uint16_t mode_no, struct vbe_mode_info_structure* vbe_mode_info)
{
    struct rm_regs r = { 0 };

    r.eax = 0x4f01;
    r.ecx = (uint32_t)mode_no;
    r.es = RM_SEG(vbe_mode_info);
    r.edi = RM_OFF(vbe_mode_info);

    rm_int(0x10, &r, &r);

    if ((r.eax & 0xffff) != 0x4f) {
        return -1;
    }

    return 0;
}
