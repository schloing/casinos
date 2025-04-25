extern void print(void);
extern void hexprint(void);
extern void diskread(void);
extern char cpuid_vendor_string[12];
extern int cpuid_feat_edx;
extern int cpuid_feat_ecx;
void cprint(const char* string);
void chexprint(const int hex);

void cboot_main()
{
    cprint("cboot\r\n");
    chexprint(cpuid_feat_edx);
    chexprint(cpuid_feat_ecx);
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
