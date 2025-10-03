OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386)

SECTIONS
{
    . = 0xf000;
    .text :
    {
        build/stage2_entry.elf(.text)
        build/int.elf(.text)
        build/stage2.elf(.text)
        build/textmode.elf(.text)
        build/vbe.elf(.text)
    }

    .data :
    {
        build/stage2.elf(.data)
        build/stage2.elf(.rodata)
        build/stage2.elf(.bss)
        build/vbe.elf(.data)
        build/vbe.elf(.rodata)
        build/textmode.elf(.data)
        build/textmode.elf(.rodata)
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
