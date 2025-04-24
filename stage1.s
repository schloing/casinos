    .text
    .code16

call _start

    .global diskread
    .type   diskread, @function
diskread:
    pusha
    movw $5, %cx
diskread.attempt:
    cmp $0, %cx
    je diskread.done
    movb $0x42, %ah
    lea dapack, %si
    movb $.drive, %dl
    int $0x13
    jc diskread.failed
    jmp diskread.done
diskread.failed:
    dec %cx
    lea str_err_diskread, %si
    call print
diskread.done:
    popa
    ret

    .global print
    .type   print, @function
print:
    pusha
    mov $0x0e, %ah
print.next:
    lodsb
    testb %al, %al
    je print.done
    int $0x10
    jmp print.next
print.done:
    popa
    ret

    .global hexprint
    .type   hexprint, @function
hexprint:
    pusha
    movw %ax, %bx
    movw $hexprint_buffer, %di
    movb $4, %cl
hexprint.next:
    rolw $4, %bx
    movb %bl, %al
    andb $0x0F, %al
    cmpb $10, %al
    jl hexprint.number
    addb $'A' - 10, %al
    jmp hexprint.done
hexprint.number:
    addb $'0', %al
hexprint.done:
    stosb
    decb %cl
    jnz hexprint.next
    movb $0, %al
    stosb
    lea hexprint_buffer, %si
    call print
    lea str_newline, %si
    call print
    popa
    ret

    .global _start
    .type   _start, @function
_start:
    lea str_hello, %si
    call print

    cli
    ljmp $0x0000, $.initcs
.initcs:
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw $0x7c00, %sp
    movw %bp, %sp
    sti

    movb $0x41, %ah
    movw $0x55aa, %bx
    movb $.drive, %dl
    int $0x13
    jc end

    movw $1, .sectors
    movw $1, %cx                # lba 0 is bootloader so start at 1
    movw $0x7e00 - 512, %ax
load_stage2:
    addw $.sector_size, %ax
    movw %cx, .lba
    movw %ax, .transfer
    call diskread
    movw %ax, %bx
    addw $510, %bx
    cmpw $0xaa55, (%bx)
    je load_stage2.done
    inc %cx
    jmp load_stage2
load_stage2.done: 
    movw $0x7e00, %bx
    jmp *%bx

end:
    lea str_err_no41, %si
    call print
    hlt
    ret

    .data
    .global .drive
    .set .drive,       0x80
    .set .sector_size, 512

    .align 16
hexprint_buffer:       .space 5

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

str_hello:             .asciz "casinoboot stage1\n\r"
str_err_no41:          .asciz "INT13h extensions not supported\n\r"
str_err_diskread:      .asciz "disk read failed (might retry)\n\r"
    .global str_newline
str_newline:           .asciz "\n\r"
