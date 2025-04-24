ENTRY(_start)
OUTPUT_FORMAT(binary)

SECTIONS
{
    . = 0x7c00;
    .stage1 : AT(0x7c00)
    {
        _sboot = .;
        build/stage1.o(.text)
        build/stage1.o(.data)
        _eboot = .;
    }

    . = 0x7dfe;
    .signature : {
        SHORT(0xaa55);
    }

    . = 0x7e00;
    .stage2 : AT(0x7e00) SUBALIGN(4)
    {
        _sboot2 = .;
        build/stage2.o(.text)
        build/stage2.o(.data)
        _eboot2 = .;
    }

    .cboot : SUBALIGN(4)
    {
        _scboot = .;
        build/cboot.o(.text)
        build/cboot.o(.data)
        build/cboot.o(.rodata*)
        _ecboot = .;
    }

    . = 0x7ffe;
    .signature2 : {
        SHORT(0xaa55);
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
