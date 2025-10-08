#ifndef TEXTMODE_H
#define TEXTMODE_H

#include <stdint.h>

#define VGA_TEXTMODE_ADDR 0xb8000
#define SCREEN_COLS 80
#define SCREEN_ROWS 25
#define PRINTF_BUFSIZ 1024

struct vga_textmode_ctx {
    uint16_t offset;
    uint8_t colour;
};

#endif
