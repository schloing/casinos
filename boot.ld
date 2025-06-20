SECTOR_SIZE     = 0x200;
STAGE1_VMA      = 0x7c00;
STAGE1_LMA      = 0;
STAGE2_VMA      = STAGE1_VMA + SECTOR_SIZE;
STAGE2_LMA      = 0x200;

ENTRY(_start)
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

    . = STAGE1_VMA;
        _sboot = .;
    .stage1 : AT(STAGE1_LMA) SUBALIGN(4)
    {
        build/stage1.o(.text*)
        build/stage1.o(.data*)
    }
        _eboot = .;
        _stage1_size = _eboot - _sboot;

    . = STAGE2_VMA;
        _sboot2 = .;
    .stage2 : AT(STAGE2_LMA) SUBALIGN(4)
    {
        build/stage2.o(.text*)
        build/stage2.o(.data*)
    }
        _eboot2 = .;
        _stage2_size = _eboot2 - _sboot2;
}
