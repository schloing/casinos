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

int vbe_set_mode(uint16_t mode_no)
{
    struct rm_regs r = { 0 };

    r.eax = 0x4f02;
    r.ebx = (uint32_t)(mode_no | 0x4000); // set lfb bit

    rm_int(0x10, &r, &r);

    if ((r.eax & 0xffff) != 0x4f) {
        printf("ebx=%d\n", r.ebx);
        return -1;
    }

    return 0;
}

#define ABSOLUTE_DIFFERENCE(a, b) ((int)(a > b ? a - b : b - a))

uint16_t vbe_find_nearest_mode(uint16_t* modes, int width, int height, int bpp,
                               struct vbe_mode_info_structure* vbe_mode_info)
{
    uint16_t best = 0x100;

    int best_res_diff = ABSOLUTE_DIFFERENCE(width * height, 640 * 480),
        best_bpp_diff = ABSOLUTE_DIFFERENCE(bpp, 8), res_diff = 0, bpp_diff = 0;

    for (int i = 0; modes[i] != 0xffff; i++) {
        if (vbe_get_mode_info(modes[i], vbe_mode_info) == -1) {
            printf("failed to get vbe mode info for mode %d\n", modes[i]);
            continue;
        }

        if ((vbe_mode_info->attributes & 0x90) != 0x90) {
            // no lfb or not supported, skip
            continue;
        }

        if (vbe_mode_info->width == width && vbe_mode_info->height == height &&
            vbe_mode_info->bpp == bpp) {
            return modes[i];
        }

        res_diff = ABSOLUTE_DIFFERENCE(width * height, vbe_mode_info->width * vbe_mode_info->height);
        bpp_diff = ABSOLUTE_DIFFERENCE(bpp, vbe_mode_info->bpp);

        if (res_diff < best_res_diff && bpp_diff < best_bpp_diff) {
            best_res_diff = res_diff;
            best_bpp_diff = bpp_diff;
            best = modes[i];
            continue;
        }
    }

    return best;
}
