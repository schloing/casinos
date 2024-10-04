#define vga_framebuffer_location 0xb8000;

int main() {
    unsigned char* vga_framebuffer = (unsigned char*)vga_framebuffer_location;
    int index = 0;
    vga_framebuffer[index++] = 'h';
    vga_framebuffer[index++] = 'h';
    vga_framebuffer[index++] = 'h';
    vga_framebuffer[index++] = 'h';
    vga_framebuffer[index++] = 'h';
    vga_framebuffer[index++] = 'h';
    vga_framebuffer[index++] = 'h';
    vga_framebuffer[index++] = 'h';
}