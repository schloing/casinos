OUTPUT_FORMAT(elf32-i386)
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

    .text : SUBALIGN(4)
    {
        bin/tinflate.o(.text)
        bin/crc32.o(.text)
        bin/tinfgzip.o(.text)
        build/decompress_unlinked.elf(.text)
    }

    .data : SUBALIGN(4)
    {
        bin/tinflate.o(.data)
        bin/crc32.o(.data)
        bin/tinfgzip.o(.data)
        build/decompress_unlinked.elf(.data)
    }

    .rodata : SUBALIGN(4)
    {
        bin/tinflate.o(.rodata)
        bin/crc32.o(.rodata)
        bin/tinfgzip.o(.rodata)
        build/decompress_unlinked.elf(.rodata)
    }
}
