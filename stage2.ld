STAGE2_VMA  = 0x10000;

OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386)

SECTIONS
{
    /DISCARD/ :
    {
        *(.bss)
        *(.eh_frame)
        *(.rela.eh_frame)
        *(.comment)
        *(.note.gnu.property)
        *(.note.GNU-stack)
        *(.dynamic)
    }

    . = STAGE2_VMA;
    .stage2 : SUBALIGN(4)
    {
        *(.text*)
        *(.data*)
        *(.rodata*)
    }
}