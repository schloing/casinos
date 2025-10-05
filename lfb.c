#include <stdint.h>
#include <video/lfb.h>
#include <video/vga.h>

struct vbe_lfb vbe_lfb = { .fg_colour = 0xffffff, .bg_colour = 0 };

void draw_pixel(int x, int y)
{
    unsigned where = x * vbe_lfb.pwidth + y * vbe_lfb.pitch;
    vbe_lfb.framebuffer[where] = vbe_lfb.fg_colour & 255;              // BLUE
    vbe_lfb.framebuffer[where + 1] = (vbe_lfb.fg_colour >> 8) & 255;   // GREEN
    vbe_lfb.framebuffer[where + 2] = (vbe_lfb.fg_colour >> 16) & 255;  // RED
}

void draw_horizontal_line(int x, int y, int length)
{
    unsigned where = x * vbe_lfb.pwidth + y * vbe_lfb.pitch;

    for (int i = x; i < x + length; i++) {
        vbe_lfb.framebuffer[where + i * vbe_lfb.pwidth] = vbe_lfb.fg_colour & 255;
        vbe_lfb.framebuffer[where + i * vbe_lfb.pwidth + 1] = (vbe_lfb.fg_colour >> 8) & 255;
        vbe_lfb.framebuffer[where + i * vbe_lfb.pwidth + 2] = (vbe_lfb.fg_colour >> 16) & 255;
    }
}

// TODO: assuming 16 bytes per char
#define VGA_FONT_BYTES_PER_CHAR 16
#define VGA_FONT_SCALE 2

void draw_char(int x, int y, const char ascii)
{
    uint8_t* glyph = (uint8_t*)&font_map[ascii * VGA_FONT_BYTES_PER_CHAR];

    for (int j = 0; j < VGA_FONT_BYTES_PER_CHAR; j++) {
        for (int i = 0; i < 8; i++) {
            if (glyph[j] & (1 << i)) {
                draw_pixel(x + VGA_FONT_BYTES_PER_CHAR - i, y + j);
            }
        }
    }
}

void draw_string(int x, int y, const char* str, int colour)
{
    int fg_colour = vbe_lfb.fg_colour;
    vbe_lfb.fg_colour = colour;

    for (int i = 0; str[i]; i++)
        draw_char(x + i * 10, y, str[i]);

    vbe_lfb.fg_colour = fg_colour;
}
