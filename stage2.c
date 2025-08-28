void write_string(int colour, const char* string) {
    volatile char* video = (volatile char*)0xB8000;
    while (*string != 0) {
        *video++ = *string++;
        *video++ = colour;
    }
}

void main_32() {
    write_string(0x0f, "casinoboot");
    while (1) {}
}
