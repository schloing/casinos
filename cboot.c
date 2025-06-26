#define cdecl __attribute__((cdecl))
extern void print(const unsigned char* str) cdecl;
extern void hexprint(const unsigned short n) cdecl;
extern void diskread(void) cdecl;
extern char cpuid_vendor_string[12];
extern int cpuid_feat_edx;
extern int cpuid_feat_ecx;

void cboot_main(void)
{
    print("cboot\r\n");
//  hexprint(cpuid_feat_edx);
//  hexprint(cpuid_feat_ecx);
    return;
}
