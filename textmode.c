#include <stdint.h>
#include <stdarg.h>
#include <stdbool.h>
#include <textmode.h>

static volatile uint16_t* _video = (volatile uint16_t*)VGA_TEXTMODE_ADDR;
static volatile struct vga_textmode_ctx _ctx = { 0, 0x0f };

static char* _itoa(int value, char* result, int base);
static void _printf_flush_buffer(int* buff_i);
static volatile char _printf_buffer[PRINTF_BUFSIZ] = { 0 };

void print(const char* string)
{
    while (*string != 0) {
        if (*string == '\n') {
            _ctx.offset += SCREEN_COLS - (_ctx.offset % SCREEN_COLS);
        }

        else {
            _video[_ctx.offset] = (_ctx.colour << 8) | *string;
            _ctx.offset += 1;
        }

        if (_ctx.offset >= SCREEN_ROWS * SCREEN_COLS) {
            // TODO: scroll
            _ctx.offset = 0;
        }

        string++;
    }
}

static void _printf_flush_buffer(int* buff_i)
{
    if (*buff_i > 0) {
        _printf_buffer[*buff_i] = '\0';
        print((const char*)_printf_buffer);
        *buff_i = 0;
    }
}

// https://www.strudel.org.uk/itoa/
static char* _itoa(int value, char* result, int base)
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

void printf(const char* fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);

    char numbuf[20];
    char* s;
    char c;
    int d;

    int buff_i = 0;
    int i = 0;

    while (fmt[i]) {
        if (fmt[i] == '%') {
            i++; // advance to format specifier

            switch (fmt[i]) {
            case 's':
                s = va_arg(ap, char*);
                while (*s) {
                    _printf_buffer[buff_i++] = *s++;
                    if (buff_i >= PRINTF_BUFSIZ) _printf_flush_buffer(&buff_i);
                }
                break;

            case 'd':
                d = va_arg(ap, int);
                _itoa(d, numbuf, 10);
                s = numbuf;
                while (*s) {
                    _printf_buffer[buff_i++] = *s++;
                    if (buff_i >= PRINTF_BUFSIZ) _printf_flush_buffer(&buff_i);
                }
                break;
                
            case 'c':
                c = (char)va_arg(ap, int);
                _printf_buffer[buff_i++] = c;
                if (buff_i >= PRINTF_BUFSIZ) _printf_flush_buffer(&buff_i);
                break;

            case '%':
                _printf_buffer[buff_i++] = '%';
                if (buff_i >= PRINTF_BUFSIZ) _printf_flush_buffer(&buff_i);
                break;

            }
        } else {
            _printf_buffer[buff_i++] = fmt[i];
            if (buff_i >= PRINTF_BUFSIZ) _printf_flush_buffer(&buff_i);
        }

        i++;
    }

    _printf_flush_buffer(&buff_i);
    va_end(ap);
}
