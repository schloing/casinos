#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <textmode.h>

static volatile uint16_t* video = (volatile uint16_t*)VGA_TEXTMODE_ADDR;

static struct vga_textmode_ctx vga_ctx = {
    .offset = 0,
    .colour = 0x0f,
};

static struct printf_buffer pbuff = {
    .buffer = { 0 },
    .size = 0,
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

// https://www.strudel.org.uk/itoa/
char* itoa(int value, char* result, int base)
{
    // check that the base if valid
    if (base < 2 || base > 36) { *result = '\0'; return result; }

    char* ptr = result, *ptr1 = result, tmp_char;
    int tmp_value;

    do {
        tmp_value = value;
        value /= base;
        *ptr++ = "zyxwvutsrqponmlkjihgfedcba9876543210123456789abcdefghijklmnopqrstuvwxyz" [35 + (tmp_value - value * base)];
    } while ( value );

    // Apply negative sign
    if (tmp_value < 0) *ptr++ = '-';
    *ptr-- = '\0';
    while(ptr1 < ptr) {
        tmp_char = *ptr;
        *ptr--= *ptr1;
        *ptr1++ = tmp_char;
    }
    return result;
}

void printf_flush_buffer()
{
    if (pbuff.size > 0) {
        pbuff.buffer[pbuff.size] = '\0';
        print((const char*)pbuff.buffer);
    }

    pbuff.size = 0;
}

void printf_buffer_write(char c)
{
    if (pbuff.size >= PRINTF_BUFSIZ) {
        printf_flush_buffer();
    }

    pbuff.buffer[pbuff.size++] = c;
}

void printf_buffer_write_s(const char* s)
{
    while (*s) {
        printf_buffer_write(*s++);
    }
}

void printf(const char* fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);

    for (const char* p = fmt; *p; p++) {
        if (*p != '%') {
            printf_buffer_write(*p);
            continue;
        }

        p++;

        switch (p[0]) {
        case 's': {
            const char* s = va_arg(ap, char*);
            printf_buffer_write_s(s);
            break;
        }
        case 'c': {
            char c = (char)va_arg(ap, int);
            printf_buffer_write(c);
            break;
        }
        case 'd': {
            char numbuf[20];
            int d = va_arg(ap, int);
            (void)itoa(d, numbuf, 10);
            printf_buffer_write_s(numbuf);
            break;
        }
        }
    }

    printf_flush_buffer();
    va_end(ap);
}
