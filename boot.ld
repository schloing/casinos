SECTOR_SIZE       = 0x200;
STAGE1_VMA        = 0x7c00;
STAGE1_LMA        = 0;

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
        build/stage1.o(.text .data .rodata)
    }
        _eboot = .;
        _stage1_size = _eboot - _sboot;

    . = STAGE1_VMA + _stage1_size;
        _sentry = .;
    .decompress : AT(STAGE1_LMA + _stage1_size) SUBALIGN(4)
    {
        build/decompress.o(.text .data .rodata)
    }
        _eentry = .;
        _entry_size = _eentry - _sentry;

        _sstage2 = .;
    .stage2 : AT(STAGE1_LMA + _stage1_size + _entry_size) SUBALIGN(4)
    {
        build/stage2.bin.o(.data)
    }
        _estage2 = .;
        _stage2_size = _estage2 - _sstage2;
}
