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

    . = 0x10000;
    .text : SUBALIGN(4)
    {
        build/stage2_entry.elf(.*)
        build/stage2.elf(.*)
    }
}
