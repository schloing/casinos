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

// TODO: organise shit irrelevant to textmode into other headers

struct printf_buffer {
    char buffer[PRINTF_BUFSIZ];
    int size;
};

char* itoa(int value, char* result, int base);
void print(const char* s);
void printf(const char* fmt, ...);
void printf_flush_buffer();
void printf_buffer_write(char c);
void printf_buffer_write_s(const char* s);

#endif
