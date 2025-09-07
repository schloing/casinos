#include <stdint.h>
#include <textmode.h>

static volatile char* video = (volatile char*)VGA_TEXTMODE_ADDR;

static struct vga_textmode_cursor cursor;

void textmode_cursor_init()
{
    cursor.x = 0;
    cursor.y = 0;
}

void printl(const char* string)
{
    while (*string != 0) {
        video[cursor.x++] = *string++;
        video[cursor.x++] = 0x0f; // white on black
    }
}
