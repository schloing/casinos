BOOT_START      = 0x7c00;
STAGE2_START    = 0x7e00;
SIG1_OFFSET     = 0x7dfe;
SECTOR_SIZE     = 0x200;

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

    . = BOOT_START;
    _sboot = .;
    .stage1 : AT(BOOT_START) SUBALIGN(4)
    {
        build/stage1.o(.text*)
        build/stage1.o(.data*)
    }
    _eboot = .;
    _stage1_size = _eboot - _sboot;

    . = SIG1_OFFSET;
    .signature :
    {
        SHORT(0xaa55)
    }

    . = STAGE2_START;
    _sboot2 = .;
    .stage2 : AT(STAGE2_START) SUBALIGN(4)
    {
        build/stage2.o(.text*)
        build/stage2.o(.data*)
    }
    _eboot2 = .;
    _stage2_size = _eboot2 - _sboot2;

    . = ALIGN(SECTOR_SIZE);
    _scboot = .;
    _cboot_lba = _scboot / SECTOR_SIZE; /* used in assembly */

    .cboot : AT(_scboot) SUBALIGN(4)
    {
        build/cboot.o(.text*)
        build/cboot.o(.data*)
        build/cboot.o(.rodata*)
        _cboot_end = .;
    }

    . = ALIGN(SECTOR_SIZE);
    _ecboot = .;
    _cboot_size = _ecboot - _scboot;
}
