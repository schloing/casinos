#include <stdint.h>
#include <textmode.h>

static volatile uint16_t* video = (volatile uint16_t*)VGA_TEXTMODE_ADDR;

static volatile struct vga_textmode_ctx ctx = { 0, 0x0f };

void print(const char* string)
{
    while (*string != 0) {
        if (*string == '\n') {
            ctx.offset += SCREEN_COLS - (ctx.offset % SCREEN_COLS);
        }

        else {
            video[ctx.offset] = (ctx.colour << 8) | *string;
            ctx.offset += 1;
        }

        if (ctx.offset >= SCREEN_ROWS * SCREEN_COLS) {
            // TODO: scroll
            ctx.offset = 0;
        }

        string++;
    }
}
