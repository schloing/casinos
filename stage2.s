    bits 32
    section .text

_start:
    extern main_32
    call main_32
    jmp $
