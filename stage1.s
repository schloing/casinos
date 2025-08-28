    .code16
    .global _start
    .att_syntax noprefix

    .section .text

_start:
    call main

    .global diskread
    .type   diskread, @function
diskread:
    push %bp
    mov %sp, %bp
    push %ax
    push %cx
    push %dx
    push %si

    mov $5, %cx
diskread.attempt:
    cmp $0, %cx
    je diskread.done
    mov $0x42, %ah
    lea dapack, %si
    mov $DRIVE, %dl
    int $0x13
    jc diskread.failed
    jmp diskread.done
diskread.failed:
    dec %cx
diskread.done:
    pop %ax
    pop %cx
    pop %dx
    pop %si
    mov %bp, %sp
    pop %bp
    ret

main:
    cli
    ljmp $0x0000, $initcs
initcs:
    xor %ax, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0x7c00, %sp
    mov %sp, %bp
    sti

    cmp $0x80, %dl
    je hdd_boot
    hlt

hdd_boot:
    mov $0x41, %ah
    mov $0x55aa, %bx
    mov $DRIVE, %dl
    int $0x13
    jc end

load_stage2:
    movw $10, .sectors
    movw $1, .lba
    movw $_sentry, .transfer
    call diskread

load_gdt:
    cli
	lgdt (gdtr)
    mov %cr0, %eax
    or $1, %eax
    mov %eax, %cr0

    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss
    ljmp $0x08, $load_gdt.setcs

    .code32
load_gdt.setcs:
    call main_32
    hlt # noreturn

    .extern main_32

    .section .data

    .set DRIVE, 0x80

gdt_start:
    .long 0x0
    .long 0x0

gdt_code:
    .word 0xffff
    .word 0x0
    .byte 0x0
    .byte 0b10011010
    .byte 0b11001111
    .byte 0x0

gdt_data:
    .word 0xffff
    .word 0x0
    .byte 0x0
    .byte 0b10010010
    .byte 0b11001111
    .byte 0x0
gdt_end:
    .global gdtr
gdtr:
    .word (gdt_end - gdt_start - 1)
    .long gdt_start

    .global dapack
    .align 16
dapack:
    .byte 0x10
    .byte 0
.sectors:
    .short 1
.transfer:
    .word 0x7e00
    .word 0
.lba:
    .long 1
    .long 0

.fill 510 - (. - _start), 1, 0
.word 0xaa55
