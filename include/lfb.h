#ifndef LFB_H
#define LFB_H

#include <stdint.h>
#include <vbe.h>

struct vbe_lfb {
    uint16_t width;
    uint16_t height;
    uint16_t pitch;
    uint16_t bpp;
    uint8_t pwidth;
    int fg_colour;
    int bg_colour;
    unsigned char* framebuffer;
};

extern struct vbe_lfb vbe_lfb;

void draw_pixel(int x, int y);
void draw_horizontal_line(int x, int y, int length);
void draw_char(int x, int y, const char ascii);
void draw_string(int x, int y, const char* str, int colour);

#endif
