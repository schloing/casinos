OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386)

SECTIONS
{
    . = 0xf000;
    .text :
    {
        build/stage2_entry.elf(.text)
        build/stage2.elf(.text)
        build/int.elf(.text)
    }

    .data :
    {
        build/stage2.elf(.data)
        build/stage2.elf(.rodata)
    }

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
}
