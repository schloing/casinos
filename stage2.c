#include <mbr.h>
#include <real.h>
#include <stdint.h>
#include <video/lfb.h>
#include <video/textmode.h>
#include <video/vbe.h>
#include <video/vga.h>

void main_32()
{
    font_map = vga_get_font_addr();
    vbe_attempt_switch(&vbe_lfb);

    for (int x = 0; x < vbe_lfb.width; x++) {
        float u = x / (float)vbe_lfb.width;
        float v = x / (float)vbe_lfb.height;
        int r = (int)(u * 255);
        int g = (int)(v * 255);
        int b = (int)(((u + v) * 0.5) * 255);
        int colour = (r << 16) | (g << 8) | b;
        vbe_lfb.fg_colour = colour;
        draw_horizontal_line(0, x, vbe_lfb.width);
    }

    draw_string(0, 0, "hello world", 0xffffff);
    
    const struct mbr_partition_table* mbr_pt = (const struct mbr_partition_table*)MBR_PARTITION_TABLE_ADDR;
    
    for (int i = 0; i < 4; i++) {
        const struct mbr_partition_table_entry entry = mbr_pt->entries[i];
        if (entry.partition_type == 0) break;
    
        if (entry.partition_type == 0x83) {
            draw_string(0, 30 + 30 * i, "linux partition", 0xffffff);
        }
    }

//    rm_int(0x19, (void*)0, (void*)0); // reboot
}
