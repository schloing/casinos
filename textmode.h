#ifndef TEXTMODE_H
#define TEXTMODE_H

#include <stdint.h>

struct vga_textmode_ctx {
    uint16_t offset;
    uint8_t colour;
};

void print(const char* string);
void printf(const char* fmt, ...);

#define VGA_TEXTMODE_ADDR 0xb8000
#define SCREEN_COLS 80
#define SCREEN_ROWS 25
#define PRINTF_BUFSIZ 128

#endif
