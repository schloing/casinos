OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386)

SECTIONS
{
    . = 0xf000;
    .text :
    {
        build/stage2_entry.elf(.text)
        build/int.elf(.real)
        *(.text)
    }

    .data :
    {
        *(.data)
    }

    .rodata :
    {
        *(.rodata)
    }

    .bss :
    {
        *(.bss)
    }

    /DISCARD/ :
    {
        *(.eh_frame)
        *(.rela.eh_frame)
        *(.comment)
        *(.note.gnu.property)
        *(.note.GNU-stack)
        *(.dynamic)
    }
}
