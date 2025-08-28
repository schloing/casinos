    .section .text
    .code16

_start_stage2:
    call stage2

cpuid_safe:
    pusha
    pushfl
    pushfl
    xorl $0x00200000, (%esp)
    popfl
    pushfl
    pop %eax
    xorl (%esp), %eax
    popfl
    andl $0x00200000, %eax
    je cpuid_safe.no
cpuid_safe.yes:
    cpuid
    push $str_cpuid
    call print
    add $2, %sp
    jmp cpuid_safe.done
cpuid_safe.no:
    push $str_cpuid_fail
    call print
    add $2, %sp
cpuid_safe.done:
    popa 
    ret

stage2:
    push $str_hello
    call print
    add $2, %sp

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
a20.failed:
    push $str_a20_fail
    call print                  # will continue to print success
    add $2, %sp
a20.finish:
    push $str_a20
    call print
    add $2, %sp

    movl $0, %eax               # vendor string
    call cpuid_safe
    movl %ebx, cpuid_vendor_string
    movl %edx, cpuid_vendor_string + 4
    movl %ecx, cpuid_vendor_string + 8
    movl $1, %eax               # cpu features
    call cpuid_safe

    movl $cpuid_feat_edx, %edx
    movl $cpuid_feat_ecx, %ecx

    call cboot_main
    hlt
hang:
    jmp hang

#   dapack from stage1
    .extern cboot_main
    .extern .transfer
    .extern .sectors
    .extern .lba

    .global cpuid_vendor_string
    .align 16
cpuid_vendor_string:       .space 12

    .global cpuid_feat_edx
    .align 16
cpuid_feat_edx:            .space 32

    .global cpuid_feat_ecx
    .align 16
cpuid_feat_ecx:            .space 32

    .global gdt
gdt:
    .quad 0
    .quad 0x00cf9a000000ffff
    .quad 0x00cf92000000ffff

str_hello:                 .asciz "casinoboot stage2\n\r"
str_cpuid:                 .asciz "cpuid call success\n\r"
str_cpuid_fail:            .asciz "cpuid call error\n\r"
str_a20:                   .asciz "a20 success\n\r"
str_a20_fail:              .asciz "a20 error. proceeding anyway\n\r"
