extern void print(void);
extern void hexprint(void);
extern void diskread(void);
void cprint(const char* string);

void cboot_main()
{
    cprint("cboot");
    return;
}

void cprint(const char* string) {
    __asm__ volatile
        (
         "lea (%0), %%si"
         : /* no */
         : "r" (string)
        );

    print();
}

void chexprint(const int hex) {
    __asm__ volatile
        (
         "mov (%0), %%di"
         : /* no */
         : "r" (hex)
        );

    hexprint();
}
