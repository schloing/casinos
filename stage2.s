    .text
    .code16
    
    jmp start_stage2

start_stage2:
    lea str_hello, %si
    call print

.macro macro_a20_check
    mov $0x112345, %edi
    mov $0x012345, %esi
    mov (%esi), %esi
    mov (%edi), %edi
    cmpsl
.endm

a20:
    macro_a20_check
    jne a20.set                 # a20 is unset, do it ourselves
    jmp a20.finish              # a20 already set
a20.set:
    inb $0x92, %al
    testb $02, %al
    jnz a20.no92
    orb $2, %al
    andb $0xfe, %al
    outb %al, $0x92
    jmp a20.finish
a20.no92:
    movw $0x2401, %ax
    int $0x15
a20.recheck:
    macro_a20_check
    je a20.finish
    lea str_a20, %si
a20.failed:
    lea str_a20_fail, %si
a20.finish:

cpuid_supported:
    pushfl
    pushfl
    xorl $0x00200000, (%esp)
    popfl
    pushfl
    pop %eax
    xorl (%esp), %eax
    popfl
    andl $0x00200000, %eax
    je cpuid_supported.no
cpuid_supported.yes:
    movl $0, %eax               # vendor string
    cpuid
cpuid_supported.no:

.extern cboot_main
    call cboot_main

    .global gdt
gdt:
    .quad 0
    .quad 0x00cf9a000000ffff
    .quad 0x00cf92000000ffff

str_hello:    .asciz "casinoboot stage2\n\r"
str_a20:      .asciz "a20 success\n\r"
str_a20_fail: .asciz "a20 error. proceeding anyway\n\r"
str_e820:     .asciz "e820 memory map loaded\n\r"
