    format elf              ; elf32
    org 0x10000
    section '.text' writeable executable
    use32
_start:
    extrn main_32
    call main_32
    jmp $
