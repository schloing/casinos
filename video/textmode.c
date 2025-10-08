#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <textmode.h>

static volatile uint16_t* video = (volatile uint16_t*)VGA_TEXTMODE_ADDR;

static struct vga_textmode_ctx vga_ctx = {
    .offset = 0,
    .colour = 0x0f,
};

void print(const char* s)
{
    while (*s != 0) {
        if (*s == '\n') {
            vga_ctx.offset += SCREEN_COLS - (vga_ctx.offset % SCREEN_COLS);
        }

        else {
            video[vga_ctx.offset] = (vga_ctx.colour << 8) | *s;
            vga_ctx.offset += 1;
        }

        if (vga_ctx.offset >= SCREEN_ROWS * SCREEN_COLS) {
            // TODO: scroll
            vga_ctx.offset = 0;
        }

        s++;
    }
}

void _putchar(char c)
{
    if (c == '\n') {
        vga_ctx.offset += SCREEN_COLS - (vga_ctx.offset % SCREEN_COLS);
    }

    else {
        video[vga_ctx.offset] = (vga_ctx.colour << 8) | c;
        vga_ctx.offset += 1;
    }

    if (vga_ctx.offset >= SCREEN_ROWS * SCREEN_COLS) {
        // TODO: scroll
        vga_ctx.offset = 0;
    }
}
