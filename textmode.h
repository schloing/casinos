#ifndef TEXTMODE_H
#define TEXTMODE_H

struct vga_textmode_cursor {
    char x;
    char y;
};

void init_textmode_cursor();
void printl(const char* string);

#define VGA_TEXTMODE_ADDR 0xb8000
#define SCREEN_COLS 80
#define SCREEN_ROWS 25

#endif
